variable "region" {
  default = "us-west2"
}

variable "availability_zone" {
  description = "The zone where the cluster will be deployed [a,b,...]"
  default     = ["a", "b"]
  type        = list(string)
}

variable "instance_group_name" {
  description = "The name of the GCP instance group"
  default     = "redpanda-group"
}

variable "broker_count" {
  description = "The number of Redpanda brokers to deploy."
  type        = number
  default     = "3"
}

variable "ha" {
  description = "Whether to use placement groups to create an HA topology for Rack Awareness"
  type        = bool
  default     = false
}

variable "client_nodes" {
  description = "The number of clients to deploy."
  type        = number
  default     = "1"
}

variable "disks" {
  description = "The number of local disks on each machine."
  type        = number
  default     = 1
}

variable "image" {
  # See https://cloud.google.com/compute/docs/images#os-compute-support
  # for an updated list.
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable machine_type {
  # List of available machines per region/ zone:
  # https://cloud.google.com/compute/docs/regions-zones#available
  default = "n2-standard-2"
}

variable monitor_machine_type {
  default = "n2-standard-2"
}

variable client_machine_type {
  default = "n2-standard-2"
}

variable "public_key_path" {
  type        = string
  description = "The public key used to ssh to the hosts"
  default     = "~/.ssh/id_rsa.pub"
}


variable "ssh_user" {
  description = "The ssh user. Must match the one in the public ssh key's comments."
}

variable "enable_monitoring" {
  default = "yes"
}

variable "labels" {
  description = "passthrough of GCP labels"
  default     = {
    "purpose"      = "redpanda-cluster"
    "created-with" = "terraform"
  }
}

variable "deployment_prefix" {
  type = string
  default = "rp-test"
}

# allow_force_destroy is only intended for demos and CI testing and to support decommissioning a cluster entirely
# enabling it will result in loss of any data or topic info stored in the bucket
variable "allow_force_destroy" {
  default     = false
  type        = bool
  description = "DANGER: Enabling this option will delete your data in Tiered Storage when terraform destroy is run. Enable this only after careful consideration of the data loss consequences."
}

variable "enable_tiered_storage" {
  description = "Enables or disables tiered storage"
  type        = bool
  default     = false
}

variable "subnet" {
  description = "The name of the subnet where the brokers will be deployed"
}

variable "allocate_brokers_public_ip" {
  default = true
  description = "whether to allocate brokers public ip addresses"
}