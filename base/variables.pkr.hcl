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
  # Just here to prevent undefined variable errors with the shared pkrvars file
  type    = string
  default = ""
}

variable "base_image_channel" {
  # Just here to prevent undefined variable errors with the shared pkrvars file
  type    = string
  default = ""
}
