variable "name" {
  type = string
  description = "(Required) This will be appended to the resources to contextualize the resources."
}

variable "domain" {
  description = "(Required) The domain users will use to access the Airflow instance."
  type = string
}

variable "hosted_zone_id" {
  description = "(Required) The HostedZone where the domain will be created."
  type = string
}

variable "mwaa_env_name" {
  type = string
  description = "(Required) Name of the pre existing MWAA environment."
}

variable "mwaa_rbac_role_name" {
  type        = string
  description = <<-EOT
    (Optional) Name of the RBAC role to be assumed by the user. Possible values are:
    - Public
    - User
    - Op
    - Admin
    - Viewer
    
    Reference: [Airflow Access Control Documentation](https://airflow.apache.org/docs/apache-airflow-providers-fab/stable/auth-manager/access-control.html#)
  EOT
  default     = "Viewer"
  validation {
    condition     = can(regex("(Public|User|Op|Admin|Viewer)", var.mwaa_rbac_role_name))
    error_message = "The value for mwaa_rbac_role_name must be one of 'Public', 'User', 'Op', 'Admin', or 'Viewer'."
  }
}

variable "mwaa_vpc_id" {
  type = string
  description = "(Required) The VPC Id of your existing MWAA environment."
}

variable "mwaa_endpoint_ips" {
  description = "(Required) List of MWAA endpoint IPs"
  type        = list(string)
  validation {
    condition     = length(var.mwaa_endpoint_ips) >= 2
    error_message = "You must specify at least two MWAA endpoint IPs."
  }
}

variable "mwaa_security_group_id" {
  description = "(Required) The security group of MWAA environment we'll attach a new rule for the alb to access Airflow webserver."
  type = string
}

variable "public_subnets_ids" {
  type        = list(string)
  description = <<-EOT
    (Required) A list of at least two Subnet IDs from your VPC, each residing in different AWS availability zones.
    The Subnet IDs must correspond to public subnets if you set `alb_access_mode` to PUBLIC, otherwise, they should be for private subnets.
  EOT
  validation {
    condition     = length(var.public_subnets_ids) >= 2
    error_message = "You must specify at least two Subnet IDs."
  }
}

variable "private_subnets_ids" {
  type        = list(string)
  description = <<-EOT
    (Required) A list of private Subnet IDs used to deploy the authentication lambda.
    You must specify at least two Subnet IDs.
  EOT
  validation {
    condition     = length(var.private_subnets_ids) >= 2
    error_message = "You must specify at least two private Subnet IDs."
  }
}

variable "alb_access_mode" {
  type        = string
  description = <<-EOT
    (Optional) Should the load balancer be internet-facing (public) or private? 
    Accepted values are:
    - PUBLIC
    - PRIVATE
    
    It defaults to PRIVATE.
  EOT
  default     = "PRIVATE"
  validation {
    condition     = can(regex("(PUBLIC|PRIVATE)", var.alb_access_mode))
    error_message = "The value for alb_access_mode must be either 'PUBLIC' or 'PRIVATE'."
  }
}

variable "alb_session_cookie_name" {
  type         = string
  description  = "(Optional) Load balancer session cookie name."
  default      = "MWAASSOAuthSessionCookie"
}

variable "cognito_context" {
  description = "(Required) OIDC Cognito context"
  type = object({
    user_pool_arn          = string
    user_pool_client_id    = string
    user_pool_domain       = string
  })
}

variable "lambda_function_bucket" {
  type = string
  description = <<-EOT
    (Required) s3 bucket where the lambda function is stored
    It should exist in the same region as the lambda function
  EOT
}

variable "lambda_function_object_key" {
  type = string
  description = "(Required) The relative path of the .zip function within this bucket"
}

variable "custom_lambda_tg_name" {
  description = "Custom name for ALB target group pointing to the lambda"
  type        = string
  default     = ""
}

variable "custom_mwaa_tg_name" {
  description = "Custom name for ALB target group pointing to the MWAA cluster"
  type        = string
  default     = ""
}
