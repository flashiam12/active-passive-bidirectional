terraform {
  required_providers {
    confluent = {
      source = "confluentinc/confluent"
    #   version = "1.76.0"
    }
  }
}

provider "confluent" {
    cloud_api_key = var.cc_cloud_api_key
    cloud_api_secret = var.cc_cloud_api_secret
}

provider "aws" {
  access_key = var.aws_key
  secret_key = var.aws_secret
  region = var.aws_region
}

variable "cc_cloud_api_key" {}
variable "cc_cloud_api_secret" {}
variable "cc_env" {}
variable "cc_service_account" {}
variable "aws_key" {}
variable "aws_secret" {}
variable "aws_region" {}
variable "aws_account_number" {}
variable "aws_vpc_id" {}
variable "aws_ec2_transit_gateway_id" {}
variable "aws_ec2_transit_gateway_resource_share_arn" {}
variable "aws_public_subnet_id_0" {}
variable "aws_public_subnet_id_1" {}
