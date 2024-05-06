resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  vpc_peering_connection_id = var.peering_connection_id
  auto_accept = true

  tags = {
    Name = "Accepted deX Peering Connection"
  }
}

resource "aws_route" "peer_route" {
  for_each                  = toset(var.route_table_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.peer_cidr_block
  vpc_peering_connection_id = var.peering_connection_id
}

resource "aws_security_group_rule" "ingress_rule" {
  for_each = { for idx, sg in var.security_group_rules : idx => sg }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = each.value.security_group_id
  cidr_blocks       = [var.peer_cidr_block]  # using the CIDR block of the peer VPC as the source
}
