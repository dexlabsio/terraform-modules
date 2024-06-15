locals {
  mwaa_sso_alb_name = "${var.mwaa_env_name}-mwaa-sso"
}

resource "aws_security_group" "alb_sg" {
  vpc_id      = var.mwaa_vpc_id
  name        = "${local.mwaa_sso_alb_name}-sg"
  description = "Security group for ALB ${local.mwaa_sso_alb_name}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "lb-logs-${local.mwaa_sso_alb_name}"
}

resource "aws_s3_bucket_policy" "lb_logs_policy" {
  bucket = aws_s3_bucket.lb_logs.id

  policy = <<POLICY
{
  "Id": "PolicyForLBLogs",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.lb_logs.arn}/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_lb" "alb" {
  name               = local.mwaa_sso_alb_name
  internal           = !var.alb_internet_facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets_ids
  enable_deletion_protection = false
  idle_timeout               = 60

  access_logs {
    bucket  = "${aws_s3_bucket.lb_logs.bucket}"
    prefix  = "access-logs"
    enabled = true
  }
  connection_logs {
    bucket  = "${aws_s3_bucket.lb_logs.bucket}"
    prefix  = "connection-logs"
    enabled = true
  }
}

resource "aws_lb_target_group" "lambda_tg" {
  name     = "lambda-target-group"
  target_type = "lambda"
  vpc_id   = var.mwaa_vpc_id
  lambda_multi_value_headers_enabled = true

  health_check {
    enabled  = false
    interval = 30
    timeout  = 5
  }
}

resource "aws_lb_target_group_attachment" "lambda_attachment" {
  target_group_arn = aws_lb_target_group.lambda_tg.arn
  target_id        = aws_lambda_function.mwaa_authx_function.arn
}

resource "aws_lb_target_group" "mwaa_endpoint_tg" {
  name     = "mwaa-endpoint-target-group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.mwaa_vpc_id

  health_check {
    protocol         = "HTTPS"
    port             = "443"
    path             = "/aws_mwaa/aws-console-sso"
    matcher          = "200-499"
  }

  target_type = "ip"
}

resource "aws_lb_target_group_attachment" "mwaa_endpoint_attachments" {
  for_each         = toset(var.mwaa_endpoint_ips)
  target_group_arn = aws_lb_target_group.mwaa_endpoint_tg.arn
  target_id        = each.value
  port             = 443
}

resource "aws_lambda_permission" "allow_elb" {
  statement_id  = "AllowExecutionFromELB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mwaa_authx_function.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.mwaa_access_cert.arn

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn              = var.cognito_context["user_pool_arn"]
      user_pool_client_id        = var.cognito_context["user_pool_client_id"]      
      user_pool_domain           = var.cognito_context["user_pool_domain"]
      session_cookie_name        = var.alb_session_cookie_name
      session_timeout            = 600

      on_unauthenticated_request = "authenticate"
      scope                      = "openid email"
    }
  }

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.mwaa_endpoint_tg.arn
  }
}

resource "aws_lb_listener_rule" "web_login_token" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 1

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn          = var.cognito_context["user_pool_arn"]
      user_pool_client_id    = var.cognito_context["user_pool_client_id"]      
      user_pool_domain       = var.cognito_context["user_pool_domain"]
      session_cookie_name    = var.alb_session_cookie_name
      session_timeout        = 600
      scope                  = "openid email"
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.mwaa_endpoint_tg.arn
  }

  condition {
    path_pattern {
      values = ["/aws_mwaa/aws-console-sso"]
    }
  }

  condition {
    query_string {
      key   = "login"
      value = "true"
    }
  }
}

resource "aws_lb_listener_rule" "create_web_login_token" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 2

  action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn          = var.cognito_context["user_pool_arn"]
      user_pool_client_id    = var.cognito_context["user_pool_client_id"]      
      user_pool_domain       = var.cognito_context["user_pool_domain"]
      session_cookie_name    = var.alb_session_cookie_name
      session_timeout        = 600
      scope                  = "openid email"
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn    
  }

  condition {
    path_pattern {
      values = ["/aws_mwaa/aws-console-sso"]
    }
  }
}

resource "aws_lb_listener_rule" "alb_logout" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 3

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }

  condition {
    path_pattern {
      values = ["/logout", "/signout", "/logout/"]
    }
  }
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
