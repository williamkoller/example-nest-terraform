variable "ami_id" {}
variable "instance_type" {}
variable "instance_name" {}
variable "region" {}
variable prefix {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}