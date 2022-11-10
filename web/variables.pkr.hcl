variable "aws_region" {
  type = string
}

variable "aws_region_copies" {
  type    = list(string)
  default = []
}

variable "az_region" {
  type = string
}

variable "az_resource_group" {
  type = string
}

variable "department" {
  type = string
}

variable "owner" {
  type = string
}

variable "prefix" {
  type = string
}

variable "base_image_bucket" {
  # HCP Packer bucket name of the parent image
  type    = string
  default = "ubuntu-focal"
}

variable "base_image_channel" {
  # HCP Packer channel of the parent image
  type = string
}
