locals {
  cc_primary_network_cidr   = "172.18.0.0/16"
  cc_secondary_network_cidr = "172.16.0.0/16"
}

data "aws_ec2_transit_gateway" "default" {
  id = var.aws_ec2_transit_gateway_id
}

data "aws_vpc" "default" {
  id = var.aws_vpc_id
}

resource "aws_ram_principal_association" "primary-network-aws-account" {
  resource_share_arn = "arn:aws:ram:${var.aws_region}:${var.aws_account_number}:resource-share/${var.aws_ec2_transit_gateway_resource_share_arn}"
  principal          = confluent_network.primay-network-transit-gateway.aws[0].account
}

resource "aws_ram_principal_association" "secondary-network-aws-account" {
  resource_share_arn = "arn:aws:ram:${var.aws_region}:${var.aws_account_number}:resource-share/${var.aws_ec2_transit_gateway_resource_share_arn}"
  principal          = confluent_network.secondary-network-transit-gateway.aws[0].account
}

resource "confluent_network" "primay-network-transit-gateway" {
  display_name     = "Primary Network For AWS Transit Gateway"
  cloud            = "AWS"
  region           = var.aws_region
  cidr             = local.cc_primary_network_cidr
  connection_types = ["TRANSITGATEWAY"]
  environment {
    id = data.confluent_environment.default.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_network" "secondary-network-transit-gateway" {
  display_name     = "Secondary Network For AWS Transit Gateway"
  cloud            = "AWS"
  region           = var.aws_region
  cidr             = local.cc_secondary_network_cidr
  connection_types = ["TRANSITGATEWAY"]
  environment {
    id = data.confluent_environment.default.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_transit_gateway_attachment" "primary" {
  display_name = "AWS Primary Network Transit Gateway Attachment"
  aws {
    ram_resource_share_arn = "arn:aws:ram:${var.aws_region}:${var.aws_account_number}:resource-share/${var.aws_ec2_transit_gateway_resource_share_arn}"
    transit_gateway_id     = data.aws_ec2_transit_gateway.default.id
    routes                 = [data.aws_vpc.default.cidr_block, local.cc_secondary_network_cidr]
  }
  environment {
    id = data.confluent_environment.default.id
  }
  network {
    id = confluent_network.primay-network-transit-gateway.id
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_transit_gateway_attachment" "secondary" {
  display_name = "AWS Secondary Network Transit Gateway Attachment"
  aws {
    ram_resource_share_arn = "arn:aws:ram:${var.aws_region}:${var.aws_account_number}:resource-share/${var.aws_ec2_transit_gateway_resource_share_arn}"
    transit_gateway_id     = data.aws_ec2_transit_gateway.default.id
    routes                 = [data.aws_vpc.default.cidr_block, local.cc_primary_network_cidr]
  }
  environment {
    id = data.confluent_environment.default.id
  }
  network {
    id = confluent_network.secondary-network-transit-gateway.id
  }
  lifecycle {
    prevent_destroy = false
  }
}

data "aws_route_table" "public_subnet_0" {
  vpc_id    = data.aws_vpc.default.id
  subnet_id = var.aws_public_subnet_id_0
}

data "aws_route_table" "public_subnet_1" {
  vpc_id    = data.aws_vpc.default.id
  subnet_id = var.aws_public_subnet_id_1
}


resource "aws_route" "cc_primary_network" {
  for_each               = toset([data.aws_route_table.public_subnet_0.id, data.aws_route_table.public_subnet_1.id])
  route_table_id         = each.value
  destination_cidr_block = confluent_network.primay-network-transit-gateway.cidr
  transit_gateway_id     = data.aws_ec2_transit_gateway.default.id
}

resource "aws_route" "cc_secondary_network" {
  for_each               = toset([data.aws_route_table.public_subnet_0.id, data.aws_route_table.public_subnet_1.id])
  route_table_id         = each.value
  destination_cidr_block = confluent_network.secondary-network-transit-gateway.cidr
  transit_gateway_id     = data.aws_ec2_transit_gateway.default.id
}
