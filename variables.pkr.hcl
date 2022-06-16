variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "az_region" {
  type    = string
  default = "Central US"
}

variable "az_resource_group" {
  type    = string
  default = "dbarr-packer"
}

variable "department" {
  type    = string
  default = "PMM"
}

variable "owner" {
  type    = string
  default = "dan.barr"
}

variable "prefix" {
  type    = string
  default = "dbarr"
}