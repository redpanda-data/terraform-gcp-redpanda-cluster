resource "google_compute_instance" "monitor" {
  count        = 1
  name         = "${var.deployment_prefix}-rp-monitor"
  tags         = ["monitor", "rp-cluster", "${var.deployment_prefix}-tf-deployment"]
  machine_type = var.monitor_machine_type
  zone         = "${var.region}-${var.availability_zone[0]}"

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

  scratch_disk {
    // 375 GB local SSD drive.
    interface = "NVME"
  }

  network_interface {
    subnetwork = var.subnet
    access_config {
    }
  }

  labels = tomap(var.labels)
}