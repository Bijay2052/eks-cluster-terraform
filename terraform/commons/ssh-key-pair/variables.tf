variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = ""
}

variable "name" {
  type        = string
  description = "Application or solution name (e.g. `app`)"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}
variable "enabled" {
  type        = bool
  default     = true
  description = "Is module enabled or not?"
}


variable "public_key_path" {
  type        = string
  description = "Path to SSH public key directory (e.g. `/secrets`)"
}

variable "private_key_path" {
  type        = string
  description = "Path to SSH private key directory (e.g. `/secrets`)"
}

variable "generate_ssh_key" {
  type        = bool
  default     = false
  description = "If set to `true`, new SSH key pair will be created"
}

variable "ssh_key_algorithm" {
  type        = string
  default     = "RSA"
  description = "SSH key algorithm"
}

variable "private_key_ext" {
  type        = string
  default     = ".pem"
  description = "Private key extension"
}

variable "public_key_ext" {
  type        = string
  default     = ".pub"
  description = "Public key extension"
}

variable "chmod_command" {
  type        = string
  default     = "chmod 600 %v"
  description = "Template of the command executed on the private key file"
}


