packer {
  required_version = ">= 1.7.0"
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

locals {
  timestamp  = regex_replace(timestamp(), "[- TZ:]", "")
  image_name = "${var.prefix}-ubuntu20-${local.timestamp}"
}

data "amazon-ami" "ubuntu-focal" {
  region = var.aws_region
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }
  most_recent = true
  owners      = ["099720109477"] # Canonical
}

source "amazon-ebs" "base" {
  region        = var.aws_region
  source_ami    = data.amazon-ami.ubuntu-focal.id
  instance_type = "t3.small"
  ssh_username  = "ubuntu"
  ami_name      = local.image_name
  ami_regions   = var.aws_region_copies

  tags = {
    owner           = var.owner
    dept            = var.department
    source_ami_id   = data.amazon-ami.ubuntu-focal.id
    source_ami_name = data.amazon-ami.ubuntu-focal.name
    Name            = local.image_name
  }
}

source "azure-arm" "base" {
  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"

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
    bucket_name = "ubuntu-focal"
    description = "Ubuntu 20.04 (focal) base images."
    bucket_labels = {
      "owner"          = var.owner
      "dept"           = var.department
      "os"             = "Ubuntu",
      "ubuntu-version" = "20.04",
    }
    build_labels = {
      "build-time" = local.timestamp
    }
  }

  sources = [
    "source.amazon-ebs.base",
    "source.azure-arm.base"
  ]

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    script          = "./update.sh"
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    inline = [
      "sudo ufw enable",
      "sudo ufw allow 22"
    ]
  }
}