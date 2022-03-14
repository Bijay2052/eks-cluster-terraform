module "label" {
  source     = "../../modules/label"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
  enabled    = var.enabled
}

locals {
  public_key_filename = format(
    "%s/%s%s",
    var.public_key_path,
    module.label.id,
    var.public_key_ext
  )

  private_key_filename = format(
    "%s/%s%s",
    var.private_key_path,
    module.label.id,
    var.private_key_ext
  )
}

resource "aws_key_pair" "imported" {
  count      = var.enabled == true && var.generate_ssh_key == false ? 1 : 0
  key_name   = module.label.id
  public_key = file(local.public_key_filename)
}

resource "tls_private_key" "default" {
  count     = var.enabled == true && var.generate_ssh_key == true ? 1 : 0
  algorithm = var.ssh_key_algorithm
}

resource "aws_key_pair" "generated" {
  count      = var.enabled == true && var.generate_ssh_key == true ? 1 : 0
  depends_on = [tls_private_key.default]
  key_name   = module.label.id
  public_key = tls_private_key.default[0].public_key_openssh
}

resource "local_file" "public_key_openssh" {
  count      = var.enabled == true && var.generate_ssh_key == true ? 1 : 0
  depends_on = [tls_private_key.default]
  content    = tls_private_key.default[0].public_key_openssh
  filename   = local.public_key_filename
}

resource "local_file" "private_key_pem" {
  count      = var.enabled == true && var.generate_ssh_key == true ? 1 : 0
  depends_on = [tls_private_key.default]
  content    = tls_private_key.default[0].private_key_pem
  filename   = local.private_key_filename
}

resource "null_resource" "chmod" {
  count      = var.enabled == true && var.generate_ssh_key == true && var.chmod_command != "" ? 1 : 0
  depends_on = [local_file.private_key_pem]
  triggers = {
    local_file_privaee_key_pem = "local_file.private_key_pem"
  }

  provisioner "local-exec" {
    command = format(var.chmod_command, local.private_key_filename)
  }
}

