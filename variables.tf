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

variable "bucket_name_prefix" {
  type        = string
  description = "Name of the S3 bucket to store the Terraform state"
  default     = "terraform-remote-state-"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the Atlantis server"
  default     = "t3a.micro"
}

variable "gh_username" {
  type        = string
  description = "GitHub username for the Atlantis server"
}

variable "gh_pat" {
  type        = string
  description = "GitHub Personal Access Token for the Atlantis server"
}

variable "gh_webhook_secret" {
  type        = string
  description = "GitHub webhook secret for the Atlantis server"
  sensitive   = true
}

variable "gh_repo_allowlist" {
  type        = string
  description = "GitHub repositories that Atlantis will be allowed to access - comma separated strings"
}

