variable "org_id" {
  description = "The Google Cloud organization id"
  type        = string
}

variable "billing_account" {
  description = "The Billing Account to associate Terraform project with"
  type        = string
}

variable "terraform_project_id" {
  description = "The id of Google Cloud Project administering Terraform (must be globally unique)"
  type        = string
}

variable "terraform_project_name" {
  description = "The name of Google Cloud Project administering Terraform"
  type        = string
  default     = "Terraform Admin Project"
}

variable "terraform_service_account_id" {
  description = "The id of service account managing this project"
  type        = string
  default     = "terraform"
}

variable "terraform_service_account_name" {
  description = "The id of service account managing this project"
  type        = string
  default     = "Terraform Service Account"
}

variable "location" {
  description = "The location where terraform state bucket is created"
  type        = string
}

variable "terraform_admins" {
  description = "The list of members who can administer terraform project itself"
  type        = list(string)
}

variable "terraformers" {
  description = "The list of members who can impersonate terraform service account"
  type        = list(string)
}
