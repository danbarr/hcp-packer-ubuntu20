variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "aws_region_copies" {
  type    = list(string)
  default = ["eu-central-1", "eu-north-1"]
}

variable "az_region" {
  type    = string
  default = "centralus"
}

variable "az_resource_group" {
  type    = string
  default = "dbarr-packer"
}

variable "department" {
  type    = string
  default = "TPMM"
}

variable "owner" {
  type    = string
  default = "dan.barr"
}

variable "prefix" {
  type    = string
  default = "dbarr"
}