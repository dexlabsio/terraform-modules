data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "DeXAthenaSparkRole" {
  name               = "deXAthenaSparkRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "athena.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name   = "AthenaSparkPermissions"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "s3:*"
          Resource = [
            "arn:aws:s3:::${var.athena_results_bucket_name}/*",
            "arn:aws:s3:::${var.athena_results_bucket_name}",
            "arn:aws:s3:::${var.dex_lakehouse_bucket_name}/*",
            "arn:aws:s3:::${var.dex_lakehouse_bucket_name}"
          ]
        },
        {
          Effect   = "Allow"
          Action   = "glue:*"
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "athena:GetWorkGroup",
            "athena:TerminateSession",
            "athena:GetSession",
            "athena:GetSessionStatus",
            "athena:ListSessions",
            "athena:StartCalculationExecution",
            "athena:GetCalculationExecutionCode",
            "athena:StopCalculationExecution",
            "athena:ListCalculationExecutions",
            "athena:GetCalculationExecution",
            "athena:GetCalculationExecutionStatus",
            "athena:ListExecutors",
            "athena:ExportNotebook",
            "athena:UpdateNotebook"
          ]
          Resource = "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "logs:CreateLogStream",
            "logs:DescribeLogStreams",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ]
          Resource = [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-athena:*",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-athena*:log-stream:*"
          ]
        },
        {
          Effect   = "Allow"
          Action   = "logs:DescribeLogGroups"
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
        },
        {
          Effect   = "Allow"
          Action   = "cloudwatch:PutMetricData"
          Resource = "*"
          Condition = {
            StringEquals = {
              "cloudwatch:namespace" = "AmazonAthenaForApacheSpark"
            }
          }
        }
      ]
    })
  }
}

resource "aws_iam_role" "DeXGlueCrawlerRole" {
  name               = "deXGlueCrawlerRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name   = "GlueCrawlerPermissions"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:PutObject"]
          Resource = "arn:aws:s3:::${var.dex_lakehouse_bucket_name}/*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "glue:*",
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:ListAllMyBuckets",
            "s3:GetBucketAcl",
            "iam:ListRolePolicies",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "cloudwatch:PutMetricData"
          ]
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = "s3:CreateBucket"
          Resource = "arn:aws:s3:::aws-glue-*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]
          Resource = [
            "arn:aws:s3:::aws-glue-*/*",
            "arn:aws:s3:::*/*aws-glue-*/*"
          ]
        },
        {
          Effect   = "Allow"
          Action   = "s3:GetObject"
          Resource = [
            "arn:aws:s3:::crawler-public*",
            "arn:aws:s3:::aws-glue-*"
          ]
        },
        {
          Effect   = "Allow"
          Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:*:*:*:/aws-glue/*"
        }
      ]
    })
  }
}

resource "aws_iam_policy" "dex_automation_policy" {
  name = "DexAutomationPolicy"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.DeXAthenaSparkRole.arn,
          aws_iam_role.DeXGlueCrawlerRole.arn
        ]
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/*",
          "arn:aws:s3:::${var.dex_lakehouse_bucket_name}",
          "arn:aws:s3:::${var.dex_lakehouse_bucket_name}/*",
          "arn:aws:s3:::${var.athena_results_bucket_name}",
          "arn:aws:s3:::${var.athena_results_bucket_name}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "iam:GetRole",
          "iam:ListRoles",
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::${var.dex_lakehouse_bucket_name}/*",
          "arn:aws:s3:::${var.athena_results_bucket_name}/*",
          "arn:aws:s3:::${var.dex_lakehouse_bucket_name}",
          "arn:aws:s3:::${var.athena_results_bucket_name}"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "athena:*",
          "glue:*",
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "logs:DescribeLogGroups"
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
      },
      {
        Effect  = "Allow"
        Action = [
          "logs:Describe*",
          "logs:Get*",
          "logs:List*",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:TestMetricFilter",
          "logs:FilterLogEvents",
          "logs:StartLiveTail",
          "logs:StopLiveTail",
          "cloudwatch:GenerateQuery"
        ]
        Resource = [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-athena:*",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-athena*:log-stream:*",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue:*",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue*:log-stream:*",
        ]
      },
    ]
  })
}

data "aws_iam_policy_document" "dex_external_role_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = var.dex_external_account_id
    }
  }
}

resource "aws_iam_role" "dex_automation" {
  name               = "deXAutomationRole"
  assume_role_policy = data.aws_iam_policy_document.dex_external_role_assume_role.json
}

resource "aws_iam_role_policy_attachment" "dex_automation_role_attachment" {
  role       = aws_iam_role.dex_automation.name
  policy_arn = aws_iam_policy.dex_automation_policy.arn
}
