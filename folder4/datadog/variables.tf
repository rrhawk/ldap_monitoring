variable "project" {
  default = "my-12345-project"
}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-c"
}
variable "name" {
  default = "name"
}
variable "machine_type" {
  # default = "f1-micro"
  default = "n1-standard-1"
}
variable "image" {
  default = "centos-cloud/centos-7"
}
variable "ssh_username" {
  default = "redhawkby"
}
variable "ssh_key" {
  default = "~/.ssh/id_rsa.pub"
}
variable "ip_cidr_range" {
  default = "10.6.1.0/24"
}
variable "firewall_ports" {
  type    = list(any)
  default = ["22", "80", "8080"]
}
variable "firewall_source_ranges" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}
variable "firewall_ports_int_tcp" {
  type    = list(any)
  default = ["0-65535"]
}
variable "firewall_ports_int_udp" {
  type    = list(any)
  default = ["0-65535"]
}
variable "firewall_source_ranges_int" {
  type    = list(any)
  default = ["10.6.1.0/24"]
}

variable "compute_address_type" {
  default = "INTERNAL"
}
variable "path_app_key" {
  default = "~/.ssh/app_key"
}
variable "path_api_key" {
  default = "~/.ssh/api_key"
}
