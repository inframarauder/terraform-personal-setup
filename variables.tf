variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

variable "access_key" {
  type        = string
  description = "AWS Access Key ID for the Terraform user"
}

variable "secret_key" {
  type        = string
  description = "AWS Secret Access Key for the Terraform user"
  sensitive   = true
}
