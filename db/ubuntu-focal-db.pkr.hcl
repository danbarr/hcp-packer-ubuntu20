packer {
  required_version = ">= 1.7.7"
  required_plugins {
    amazon = {
      version = "~>1.0"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      version = "~>1.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

data "hcp-packer-iteration" "ubuntu20-base" {
  bucket_name = var.base_image_bucket
  channel     = var.base_image_channel
}

data "hcp-packer-image" "ubuntu20-base-aws" {
  bucket_name    = data.hcp-packer-iteration.ubuntu20-base.bucket_name
  iteration_id   = data.hcp-packer-iteration.ubuntu20-base.id
  cloud_provider = "aws"
  region         = var.aws_region
}

data "hcp-packer-image" "ubuntu20-base-azure" {
  bucket_name    = data.hcp-packer-iteration.ubuntu20-base.bucket_name
  iteration_id   = data.hcp-packer-iteration.ubuntu20-base.id
  cloud_provider = "azure"
  region         = var.az_region
}

locals {
  timestamp  = regex_replace(timestamp(), "[- TZ:]", "")
  image_name = "${var.prefix}-ubuntu20-db-${local.timestamp}"
}

source "amazon-ebs" "base" {
  region        = var.aws_region
  source_ami    = data.hcp-packer-image.ubuntu20-base-aws.id
  instance_type = "t3.small"
  ssh_username  = "ubuntu"
  ami_name      = local.image_name
  ami_regions   = var.aws_region_copies

  tags = {
    owner         = var.owner
    dept          = var.department
    source_ami_id = data.hcp-packer-image.ubuntu20-base-aws.id
    Name          = local.image_name
  }
}

source "azure-arm" "base" {
  os_type                                  = "Linux"
  custom_managed_image_name                = data.hcp-packer-image.ubuntu20-base-azure.labels.managed_image_name
  custom_managed_image_resource_group_name = data.hcp-packer-image.ubuntu20-base-azure.labels.managed_image_resourcegroup_name

  build_resource_group_name         = var.az_resource_group
  vm_size                           = "Standard_A2_v2"
  managed_image_name                = local.image_name
  managed_image_resource_group_name = var.az_resource_group

  azure_tags = {
    owner = var.owner
    dept  = var.department
  }
  use_azure_cli_auth = true
}

build {
  hcp_packer_registry {
    bucket_name = "ubuntu-focal-db"
    description = "Ubuntu 20.04 (focal) MariaDB database server image."
    bucket_labels = {
      "owner"          = var.owner
      "dept"           = var.department
      "os"             = "Ubuntu",
      "ubuntu-version" = "20.04",
      "app"            = "mariadb",
    }
    build_labels = {
      "build-time" = local.timestamp
    }
  }

  sources = [
    "source.amazon-ebs.base",
    "source.azure-arm.base"
  ]

  # Make sure cloud-init has finished
  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get -qy update",
      "sudo apt-get -qy -o \"Dpkg::Options::=--force-confdef\" -o \"Dpkg::Options::=--force-confold\" install mariadb-server mariadb-client"
    ]
  }
}