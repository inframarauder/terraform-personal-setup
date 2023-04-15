# terraform-personal-setup

Terraform configuration to setup my personal terraform workflow.

- remote backend : S3 bucket with SSE encryption, dynamodb table (for state locking)
- atlantis : EC2 instance with atlantis server and GitHub webhook configured for PR automation
