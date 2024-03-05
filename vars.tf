variable "region" {
  default = "us-west2"
  type    = string
}

variable "availability_zone" {
  description = "The zone where the cluster will be deployed [a,b,...]"
  default     = ["a", "b"]
  type        = list(string)
}

variable "broker_count" {
  description = "The number of Redpanda brokers to deploy."
  type        = number
  default     = 3
}

variable "ha" {
  description = "Whether to use placement groups to create an HA topology for Rack Awareness"
  type        = bool
  default     = false
}

variable "client_count" {
  description = "The number of clients to deploy."
  type        = number
  default     = 1
}

variable "connect_count" {
  description = "The number of connect instances to deploy."
  type        = number
  default     = 0
}

variable "disks" {
  description = "The number of local disks on each machine."
  type        = number
  default     = 1
}

variable "image" {
  # See https://cloud.google.com/compute/docs/images#os-compute-support
  # for an updated list.
  default = "ubuntu-os-cloud/ubuntu-2204-lts"
  type    = string
}

variable broker_machine_type {
  # List of available machines per region/ zone:
  # https://cloud.google.com/compute/docs/regions-zones#available
  default = "n2-standard-2"
  type    = string
}

variable monitor_machine_type {
  default = "n2-standard-2"
  type    = string
}

variable client_machine_type {
  default = "n2-standard-2"
  type    = string
}

variable "connect_machine_type" {
  default = "n2-standard-2"
  type    = string
}

variable "public_key_path" {
  type        = string
  description = "The public key used to ssh to the hosts"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  description = "The ssh user. Must match the one in the public ssh key's comments."
  type        = string
}

variable "enable_monitoring" {
  default = true
  type    = bool
}

variable "labels" {
  description = "passthrough of GCP labels"
  type        = map(string)
  default     = {
    "purpose"      = "redpanda-cluster"
    "created-with" = "terraform"
  }
}

variable "deployment_prefix" {
  type    = string
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
  type        = string
}

variable "allocate_brokers_public_ip" {
  default     = true
  type        = bool
  description = "whether to allocate brokers public ip addresses"
}

variable "hosts_file" {
  default     = "hosts.ini"
  description = "path and name for ansible hosts file generated as output of this module"
  type        = string
}