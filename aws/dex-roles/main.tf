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
          Resource = "arn:aws:athena:${var.region_of_choice}:${var.aws_account_id}:workgroup/*"
        },
        {
          Sid      = "VisualEditor0"
          Effect   = "Allow"
          Action   = [
            "logs:CreateLogStream",
            "logs:DescribeLogStreams",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ]
          Resource = [
            "arn:aws:logs:${var.region_of_choice}:${var.aws_account_id}:log-group:/aws-athena:*",
            "arn:aws:logs:${var.region_of_choice}:${var.aws_account_id}:log-group:/aws-athena*:log-stream:*"
          ]
        },
        {
          Sid      = "VisualEditor1"
          Effect   = "Allow"
          Action   = "logs:DescribeLogGroups"
          Resource = "arn:aws:logs:${var.region_of_choice}:${var.aws_account_id}:log-group:*"
        },
        {
          Sid      = "VisualEditor2"
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

resource "aws_iam_user" "dex_user" {
  name = var.dex_user_name
}

resource "aws_iam_user_login_profile" "dex_user_login" {
  user    = aws_iam_user.dex_user.name
  password_reset_required = false
}

resource "aws_iam_user_policy" "dex_user_policy" {
  name = "DexUserPolicy"
  user = aws_iam_user.dex_user.name
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Sid    = "VisualEditor0"
          Effect = "Allow"
          Action = "iam:PassRole"
          Resource = [
            aws_iam_role.DeXAthenaSparkRole.arn,
            aws_iam_role.DeXGlueCrawlerRole.arn
          ]
        },
        {
          Sid    = "VisualEditor1"
          Effect = "Allow"
          Action = "iam:PassRole"
          Resource = [
            "arn:aws:athena:${var.region_of_choice}:${var.aws_account_id}:workgroup/*",
            "arn:aws:s3:::${var.dex_lakehouse_bucket_name}",
            "arn:aws:s3:::${var.dex_lakehouse_bucket_name}/*",
            "arn:aws:s3:::${var.athena_results_bucket_name}",
            "arn:aws:s3:::${var.athena_results_bucket_name}/*"
          ]
        },
        {
          Sid      = "VisualEditor2"
          Effect   = "Allow"
          Action   = [
            "iam:GetRole",
            "s3:ListAllMyBuckets",
            "iam:ListRoles",
            "athena:*",
            "glue:*",
            "glue:GetTable",
            "s3:ListBucket"
          ]
          Resource = "*"
        },
        {
          Sid    = "VisualEditor3"
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
          Action   = "iam:ChangePassword"
          Resource = aws_iam_user.dex_user.arn
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListVirtualMFADevices",
                "iam:CreateVirtualMFADevice",
                "iam:DeleteVirtualMFADevice"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "CloudWatchLogsReadOnlyAccess",
            "Effect": "Allow",
            "Action": [
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
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetLoginProfile",
                "iam:ListAccessKeys",
                "iam:ListSigningCertificates",
                "iam:GetUser",
                "iam:ListMFADevices",
                "iam:ListUserTags",
                "iam:GetAccessKeyLastUsed",
                "iam:CreateAccessKey",
                "iam:DeleteAccessKey",
                "iam:UpdateAccessKey",
                "iam:EnableMFADevice"
            ],
            "Resource": [
                aws_iam_user.dex_user.arn
            ]
        }
      ]
    })
}
