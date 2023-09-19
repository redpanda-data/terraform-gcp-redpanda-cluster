resource "local_file" "hosts_ini" {
  content = templatefile("${path.module}/hosts.ini.tpl",
    {
      broker_public_ips          = var.allocate_brokers_public_ip ? google_compute_instance.broker[*].network_interface[0].access_config[0].nat_ip : google_compute_instance.broker[*].network_interface[0].network_ip
      broker_private_ips         = google_compute_instance.broker[*].network_interface[0].network_ip
      client_public_ips          = google_compute_instance.client[*].network_interface[0].access_config[0].nat_ip
      client_private_ips         = google_compute_instance.client[*].network_interface[0].network_ip
      monitor_public_ip          = google_compute_instance.monitor[0].network_interface[0].access_config[0].nat_ip
      monitor_private_ip         = google_compute_instance.monitor[0].network_interface[0].network_ip
      ssh_user                   = var.ssh_user
      enable_monitoring          = var.enable_monitoring
      rack                       = length(var.availability_zone) == 1 ? google_compute_instance.broker[*].name : google_compute_instance.broker[*].zone
      rack_awareness             = var.ha || length(var.availability_zone) > 1
      availability_zone          = google_compute_instance.broker[*].zone
      cloud_storage_region       = var.region
      tiered_storage_enabled     = var.enable_tiered_storage
      tiered_storage_bucket_name = try(google_storage_bucket.tiered_storage[0].name, "")
    }
  )
  filename = "${path.module}/hosts.ini"
}
