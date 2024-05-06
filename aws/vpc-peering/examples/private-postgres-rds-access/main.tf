module "dex_vpc_peering" {
  source                = "../.."

  // You can find this value in your VPC's peering list in the AWS
  // console or by asking deX support who is onboarding you.
  peering_connection_id = "pcx-00073dd6f9333b696"
  peer_cidr_block       = "10.40.0.0/21"

  route_table_ids       = [
    "rtb-0b5e46048608c6588",
    "rtb-0adf7f5e1e26626a9",
    "rtb-0d45ec1cfc99d633b",
    "rtb-0eb734efd3d75ede4",
    "rtb-0e953e4c7383d558d",
  ]

  security_group_rules  = [
    {
      from_port         = 5432,
      to_port           = 5432,
      protocol          = "tcp",
      security_group_id = "sg-02d0ffd0576e47111"
    }
  ]
}
