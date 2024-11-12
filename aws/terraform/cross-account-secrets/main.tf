# Allow access to secrets
resource "aws_iam_policy" "secret_manager_access" {
  name        = "SecretManagerAccessPolicy"
  description = "Allows access to secrets in AWS Secrets Manager"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Principal = {
          AWS = var.external_role_arn
        }
        Action   = "secretsmanager:*"
        Resource = var.secret_arn_list
      }
    ]
  })
}

resource "aws_secretsmanager_secret_policy" "attach_policy" {
  for_each = toset(var.secrets_arn_list)

  secret_arn = each.value
  policy     = aws_iam_policy.secret_manager_access.policy
}

# Allow secrets decryption
resource "aws_kms_key_policy" "secrets_decryption" {
  for_each = toset(var.kms_keys_id_list)
  key_id   = each.value

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable Decryption Permissions"
        Effect    = "Allow"
        Principal = {
          AWS = var.external_role_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
    ]
  })
}
