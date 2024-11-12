output "peering_connection_id" {
  value       = aws_vpc_peering_connection_accepter.peer_accepter.id
  description = "The ID of the accepted VPC peering connection."
}

output "route_table_ids" {
  value       = var.route_table_ids
  description = "The IDs of the route tables that have been updated with peering routes."
}

output "security_group_ids" {
  value       = [for rule in var.security_group_rules : rule.security_group_id]
  description = "The IDs of the security groups that have ingress rules added."
}
