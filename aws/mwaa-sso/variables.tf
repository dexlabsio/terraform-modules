variable "aws_region" {
  description = "(Required) Region where to deploy the SSO resources."
  type        = string
}

variable "aws_account_id" {
  type = string
  description = "AWS account ID."
}

variable "mwaa_env_name" {
  type = string
  description = "Name of the pre existing MWAA environment."
}

variable "company_name" {
  type = string
  description = "Name of the Company. This will be appended to the resources to contextualize the resources."
}

variable "mwaa_rbac_role_name" {
  type = string
  description = "Name of the rbac role to be assumed by the user. Possible values are: Public, User, Op, Admin, Viewer. Ref: https://airflow.apache.org/docs/apache-airflow-providers-fab/stable/auth-manager/access-control.html#"
}

variable "mwaa_vpc_id" {
  type = string
  description = "The VPC Id of your existing MWAA environment."
}

variable "public_subnets_ids" {
  type        = list(string)
  description = "At least two SubnetIds from your VpcId residing in two different AWS availability zones. The SubnetIds must be for public subnets if you set InternetFacing to true, or they must be for private subnets."
}

variable "private_subnets_ids" {
  type        = list(string)
  description = "These private subnets will be used to deploy the AuthenticationLambda."
}

variable "alb_internet_facing" {
  type         = bool
  description  = "Should the Load balancer be internet facing(public)? It's private by default."
  default      = false
}

variable "alb_session_cookie_name" {
  type         = string
  description  = "LoadBalancer session cookie name."
}

variable "mwaa_endpoint_ips" {
  description = "List of MWAA endpoint IPs"
  type        = list(string)
}

variable "cognito_context" {
  description = "OIDC Cognito context"
  type = object({
    user_pool_arn          = string
    user_pool_client_id    = string
    user_pool_domain       = string
  })
}
