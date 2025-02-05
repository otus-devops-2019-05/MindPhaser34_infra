variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable "count" {
  description = "Number of VMs"
  default     = "1"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
