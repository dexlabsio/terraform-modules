output "cross_account_access_role_arn" {
  description = "deX team will need this role ARN so that they can configure automation within your account."
  value = aws_iam_role.dex_automation.arn
}

output "cross_account_access_role_name" {
  description = "deX team will need this role name so that they can configure automation within your account."
  value = aws_iam_role.dex_automation.name
}

output "cross_account_id" {
  description = "deX team will need your account ID to create external access policies and securely configure cross-account access."
  value = data.aws_caller_identity.current.account_id
}
