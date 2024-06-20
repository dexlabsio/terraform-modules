data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRoleMwaaAuth${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  path = "/service-role/"
}

# IAM Policy for Lambda Logging and EC2 Operations
resource "aws_iam_role_policy" "lambda_execution_policy" {
  name   = "lambda-execution-policy"
  role   = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogGroupFields",
          "logs:DescribeLogGroups"
        ],
        Resource = "arn:aws:logs:${local.region}:${local.account_id}:log-group:*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource = [
          "arn:aws:s3:::dex-public-assets/*",
          "arn:aws:s3:::dex-public-assets/"
        ]
      }
    ]
  })
}

variable "mwaa_roles_names" {
  type    = list(string)
  default = ["Admin", "User", "Viewer", "Op", "Public"]
}

# IAM Roles for Lambda to interact with MWAA
resource "aws_iam_role" "lambda_mwaa_rbac_role" {
  for_each = toset(var.mwaa_roles_names)

  name = "Lambda${each.key}RbacRole${var.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      },
      {
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        },
        Action    = "sts:AssumeRole"
      },
      {
        Effect    = "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_execution_role.arn
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "MwaaRbacPolicy"
    policy = jsonencode({
      Version   = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = [
            "airflow:CreateWebLoginToken",
            "sts:AssumeRole"
          ],
          Resource = "arn:aws:airflow:${local.region}:${local.account_id}:role/${var.mwaa_env_name}/${each.key}"
        }
      ]
    })
  }

  path = "/service-role/"
}

# IAM Policy to allow Lambda to assume MWAA roles and interact with Airflow environments
resource "aws_iam_role_policy" "lambda_assume_mwaa_roles" {
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = [for role in aws_iam_role.lambda_mwaa_rbac_role : role.arn]
      },
      {
        Effect   = "Allow",
        Action   = "airflow:GetEnvironment",
        Resource = "arn:aws:airflow:${local.region}:${local.account_id}:environment/*"
      }
    ]
  })
}

## Auth Lambda
resource "aws_cloudwatch_log_group" "mwaa_authx_function" {
  name              = "/aws/lambda/MwaaAuthxFunction${var.name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "mwaa_authx_function" {
  s3_bucket = "dex-public-assets"
  s3_key    = "sso/auth/lambda/MwaaAuthxFunction.zip"
  function_name = "MwaaAuthxFunction${var.name}"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  vpc_config {
    subnet_ids         = var.private_subnets_ids
    security_group_ids = [aws_security_group.alb_sg.id]
  }
  environment {
    variables = {
      MWAA_ENVIRONMENT_NAME  = var.mwaa_env_name
      RBAC_ROLE_NAME         = var.mwaa_rbac_role_name
      RBAC_ADMIN_ROLE_ARN    = "arn:aws:iam::${local.account_id}:role/service-role/LambdaAdminRbacRole${var.name}"
      RBAC_USER_ROLE_ARN     = "arn:aws:iam::${local.account_id}:role/service-role/LambdaUserRbacRole${var.name}"
      RBAC_VIEWER_ROLE_ARN   = "arn:aws:iam::${local.account_id}:role/service-role/LambdaViewerRbacRole${var.name}"
      RBAC_OP_ROLE_ARN       = "arn:aws:iam::${local.account_id}:role/service-role/LambdaOpRbacRole${var.name}"
      RBAC_PUBLIC_ROLE_ARN   = "arn:aws:iam::${local.account_id}:role/service-role/LambdaPublicRbacRole${var.name}"
      PUBLIC_KEY_ENDPOINT    = "https://public-keys.auth.elb.${local.region}.amazonaws.com/"
      ALB_COOKIE_NAME        = var.alb_session_cookie_name
    }
  }
  timeout = 60
  
  depends_on = [
    aws_cloudwatch_log_group.mwaa_authx_function,
  ]
}
