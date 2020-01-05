variable "project_name" {
    description = "A project name to associate with resources"
}
variable "terraform_project" {
    description = "Name of the Terraform project"
}
variable "dns_support" {
    default = true
}
variable "dns_hostnames" {
    default = true
}

variable "num_public_subnets" {
    default = 2
}

variable "num_private_subnets" {
    default = 2
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "assign_pub_ip" {
    type = bool
    default = false
}
