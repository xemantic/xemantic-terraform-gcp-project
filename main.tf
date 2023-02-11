resource "google_project" "terraform" {
  org_id              = var.org_id
  billing_account     = var.billing_account
  project_id          = var.terraform_project_id
  name                = var.terraform_project_name
  auto_create_network = false
  skip_delete         = true
}

resource "google_project_service" "cloudbilling" {
  project    = google_project.terraform.project_id
  service    = "cloudbilling.googleapis.com"
  depends_on = [google_project.terraform]
}

resource "google_project_service" "cloudresourcemanager" {
  project    = google_project.terraform.project_id
  service    = "cloudresourcemanager.googleapis.com"
  depends_on = [google_project.terraform]
}

resource "google_project_service" "iam" {
  project    = google_project.terraform.project_id
  service    = "iam.googleapis.com"
  depends_on = [google_project.terraform]
}

resource "google_project_service" "serviceusage" {
  project    = google_project.terraform.project_id
  service    = "serviceusage.googleapis.com"
  depends_on = [google_project.terraform]
}

resource "google_project_default_service_accounts" "terraform" {
  project = google_project.terraform.project_id
  action  = "DELETE"
}

resource "google_service_account" "terraform" {
  project      = google_project.terraform.project_id
  account_id   = var.terraform_service_account_id
  display_name = var.terraform_service_account_name
}

// google_service_account creation is eventually consistent, to prevent errors we wait a bit
resource "time_sleep" "after_terraform_service_account" {
  depends_on      = [google_service_account.terraform]
  create_duration = "10s"
}

data "google_iam_policy" "terraform" {
  binding {
    role    = "roles/owner"
    members = [google_service_account.terraform.member]
  }
}

resource "google_project_iam_policy" "terraform" {
  project     = google_project.terraform.project_id
  policy_data = data.google_iam_policy.terraform.policy_data
  depends_on  = [
    time_sleep.after_terraform_service_account,
    google_project_service.iam
  ]
}

resource "google_storage_bucket" "terraform" {
  project  = google_project.terraform.project_id
  location = var.location
  // bucket names have to be globally unique, as project ids,
  // so the project_id is a safe bet here
  name     = google_project.terraform.project_id
  versioning {
    enabled = true
  }
}

resource "google_service_account_iam_binding" "terraform_impersonation" {
  service_account_id = google_service_account.terraform.id
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = var.terraformers
}

resource "google_organization_iam_member" "terraform_project_creator" {
  org_id = var.org_id
  role   = "roles/resourcemanager.projectCreator"
  member = google_service_account.terraform.member
}

resource "google_organization_iam_member" "terraform_project_iam_admin" {
  org_id = var.org_id
  role   = "roles/resourcemanager.projectIamAdmin"
  member = google_service_account.terraform.member
}

resource "google_organization_iam_member" "terraform_billing_user" {
  org_id = var.org_id
  role   = "roles/billing.user"
  member = google_service_account.terraform.member
}
