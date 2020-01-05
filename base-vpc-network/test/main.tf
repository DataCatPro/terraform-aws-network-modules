provider "aws" {
    region = "us-east-2"
}

module "vpc_net" {
  source = "../"
  project_name = "test-vpc-network-module"
  terraform_project = "vpc-network"
  ssh_cidr = "0.0.0.0/0" # Should not use 0.0.0.0/0 in actual environment; extends universal access
}
