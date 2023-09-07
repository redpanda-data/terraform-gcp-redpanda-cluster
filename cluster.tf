resource "random_uuid" "cluster" {}

locals {
  uuid          = random_uuid.cluster.result
}

resource "google_compute_resource_policy" "broker-rp" {
  name   = "${var.deployment_prefix}-broker-rp"
  region = var.region
  group_placement_policy {
    availability_domain_count = var.ha ? max(3, var.broker_count) : 1
  }
  count = var.ha ? 1 : 0
}

resource "google_compute_instance" "broker" {
  count             = var.broker_count
  name              = "${var.deployment_prefix}-rp-node-${count.index}"
  tags              = ["broker", "rp-cluster", "${var.deployment_prefix}-tf-deployment"]
  zone              = "${var.region}-${var.availability_zone[count.index % length(var.availability_zone)]}"
  machine_type      = var.machine_type

  dynamic "service_account" {
    for_each = var.enable_tiered_storage ? [1] : []
    content {
      email  = google_service_account.tiered_storage[0].email
      scopes = ["https://www.googleapis.com/auth/devstorage.full_control"]
    }
  }

  // GCP does not give you visibility nor control over which failure domain a resource has been placed into
  // (https://issuetracker.google.com/issues/256993209?pli=1). So the only way that we can guarantee that
  // specific nodes are in separate racks is to put them into entirely separate failure domains - basically one
  // broker per failure domain, and we are limited by the number of failure domains (at the moment 8).
  resource_policies = (var.ha && var.broker_count <= 8) ? [
    google_compute_resource_policy.broker-rp[0].id
  ] : null

  metadata = {
    ssh-keys = <<KEYS
${var.ssh_user}:${file(abspath(var.public_key_path))}
KEYS
  }

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  dynamic "scratch_disk" {
    for_each = range(var.disks)
    content {
      // 375 GB local SSD drive.
      interface = "NVME"
    }
  }
  network_interface {
    subnetwork = var.subnet
    access_config {}
  }

  labels = tomap(var.labels)
  depends_on = [
    google_project_service.cloud_resource_manager
  ]
}

resource "google_compute_instance_group" "broker" {
  name      = "${var.deployment_prefix}-rp-group"
  count     = length(var.availability_zone)
  zone      = "${var.region}-${var.availability_zone[count.index]}"
  instances = tolist(concat(
    [for i in google_compute_instance.broker.* : i.self_link if i.zone == "${var.region}-${var.availability_zone[count.index]}"],
    [for i in google_compute_instance.monitor.* : i.self_link if i.zone == "${var.region}-${var.availability_zone[count.index]}"],
    [for i in google_compute_instance.client.* : i.self_link if i.zone == "${var.region}-${var.availability_zone[count.index]}"]
   )
  )
}