variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "aws_region" {
  default = "us-east-1"
}

variable "az" {
  default = "us-east-1a"
}

variable "instance_username" {
  default = "ec2-user"
}

# This is ui base AMI
variable "amis" {
  type = "map"

  default = {
    us-east-1 = "ami-0160d1e631c65ed65"
  }
}

variable "instance_type" {
  description = "Size of the instance"
  default     = "m5a.xlarge"
}

variable "root_volume_size" {
  default = "250"
}

variable "path_to_private_key" {
  default = "ec2-oracle-keypair"
}

variable "path_to_public_key" {
  default = "ec2-oracle-keypair.pub"
}

variable "primary_eni_id" {
  default = "eni-017250d10db93f197"
}




