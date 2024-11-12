variable "peering_connection_id" {
  description = "The ID of the VPC peering connection to be accepted."
}

variable "route_table_ids" {
  description = "The IDs of the route tables to add the peering routes to."
  type        = list(string)
}

variable "peer_cidr_block" {
  description = "The CIDR block of the peer VPC."
}

variable "security_group_rules" {
  description = "A list of maps where each map defines from_port, to_port, protocol, and security_group_id for an ingress rule."
  type        = list(object({
    from_port         = number
    to_port           = number
    protocol          = string
    security_group_id = string
  }))
}
