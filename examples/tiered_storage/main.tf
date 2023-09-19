variable "gcp_creds" {
  default = ""
  description = "base64 encoded json GCP key file for a service account"
}

provider "google" {
  project = var.project_id
  region = var.region
  credentials = base64decode(var.gcp_creds)
}

variable "region" {
  type = string
  default = "us-central1"
}
module "redpanda-cluster" {
  source = "../../"
  ssh_user = "ubuntu"
  subnet = google_compute_subnetwork.test-subnet.id
  region = var.region
  enable_tiered_storage = true
  allow_force_destroy = true
  deployment_prefix = var.deployment_prefix
  public_key_path = var.public_key_path
}

resource "google_compute_network" "test-net" {
  name                    = "${var.deployment_prefix}-tiered-net"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "test-subnet" {
  name          = "${var.deployment_prefix}-test-sub"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.test-net.self_link
}

resource "google_compute_firewall" "test-fire" {
  name    = "${var.deployment_prefix}-test-fire"
  network = google_compute_network.test-net.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "3000", "8888", "8889", "9090", "9092", "9100", "9644", "33145"]
  }

  source_ranges = ["0.0.0.0/0"]
}

variable "deployment_prefix" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "project_id" {
  default = ""
}