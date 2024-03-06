resource "google_compute_instance" "connect" {
  count        = var.connect_count
  name         = "${var.deployment_prefix}-rp-connect-${count.index}"
  tags         = ["connect", "rp-cluster", "${var.deployment_prefix}-tf-deployment"]
  machine_type = var.connect_machine_type
  zone         = "${var.region}-${var.availability_zone[count.index % length(var.availability_zone)]}"

  metadata = {
    ssh-keys = <<KEYS
${var.ssh_user}:${file(var.public_key_path)}
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