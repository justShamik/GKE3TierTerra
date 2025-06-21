# modules/iam/main.tf
resource "google_service_account" "test-automation-user" {
  account_id   = var.project_name
  project      = var.project_name
  display_name = "Test Automation User Service Account"
}

resource "google_project_iam_binding" "storage-admin" {
  project    = var.project_name
  role       = "roles/storage.admin"
  members    = ["serviceAccount:${google_service_account.test-automation-user.email}"]
  depends_on = [google_service_account.test-automation-user]
}

resource "google_project_iam_member" "artifact_reader" {
  project = var.project_name
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.test-automation-user.email}"
}

resource "google_project_iam_binding" "compute-admin" {
  project    = var.project_name
  role       = "roles/compute.admin"
  members    = ["serviceAccount:${google_service_account.test-automation-user.email}"]
  depends_on = [google_service_account.test-automation-user]
}

resource "google_project_iam_binding" "container-admin" {
  project    = var.project_name
  role       = "roles/container.admin"
  members    = ["serviceAccount:${google_service_account.test-automation-user.email}"]
  depends_on = [google_service_account.test-automation-user]
}