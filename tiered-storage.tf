resource "google_storage_bucket" "tiered_storage" {
  count = var.enable_tiered_storage ? 1 : 0
  name     = "${var.deployment_prefix}-${local.uuid}"
  location = var.region
  force_destroy = var.allow_force_destroy
}

resource "google_service_account" "tiered_storage" {
  count = var.enable_tiered_storage ? 1 : 0
  account_id   = "${var.deployment_prefix}-rp-admin"
  display_name = "Tiered Storage service account for RedPanda"
  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_storage_bucket_iam_binding" "ts_iam" {
  count = var.enable_tiered_storage ? 1 : 0
  bucket = google_storage_bucket.tiered_storage[0].name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.tiered_storage[0].email}"
  ]

  depends_on = [
    google_project_service.iam_api
  ]
}

resource "google_project_service" "iam_api" {
  service = "iam.googleapis.com"
  disable_dependent_services = false
}


resource "google_project_service" "cloud_resource_manager" {
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = false
}