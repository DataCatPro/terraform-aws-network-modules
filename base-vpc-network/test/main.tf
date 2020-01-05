provider "aws" {
    region = "us-east-2"
}

module "vpc_net" {
  source = "../"
  project_name = "test-vpc-network-module"
  terraform_project = "vpc-network"
}
