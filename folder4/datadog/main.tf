provider "google" {
  project = var.project
  region  = var.region
}


resource "google_compute_network" "vpc_net" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "vpc_subnet_public" {
  name          = "${var.name}-vpc-subnet-public"
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_net.id
}


resource "google_compute_firewall" "external-firewall" {
  name    = "${var.name}-external-rule"
  network = google_compute_network.vpc_net.name
  allow {
    protocol = "tcp"
    ports    = var.firewall_ports
  }
  source_ranges = var.firewall_source_ranges
}


resource "google_compute_firewall" "internal-firewall" {
  name    = "${var.name}-internal-rule"
  network = google_compute_network.vpc_net.name
  allow {
    protocol = "tcp"
    ports    = var.firewall_ports_int_tcp
  }
  allow {
    protocol = "udp"
    ports    = var.firewall_ports_int_udp
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = var.firewall_source_ranges_int
}

resource "google_compute_address" "datadog_server_address" {
  name         = "${var.name}-datadog-server-address"
  subnetwork   = google_compute_subnetwork.vpc_subnet_public.id
  address_type = var.compute_address_type
  region       = var.region
}


resource "google_compute_instance" "datadog_instance" {
  name         = "${var.name}-datadog-server-instance"
  zone         = var.zone
  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_key)}"
  }
  metadata_startup_script = templatefile("run_server.sh", { API_KEY = "${file(var.path_api_key)}" })
  network_interface {
    network    = google_compute_network.vpc_net.name
    network_ip = google_compute_address.datadog_server_address.address
    subnetwork = google_compute_subnetwork.vpc_subnet_public.name
    access_config {
    }
  }
}


provider "datadog" {
  api_key = "xxx"
  app_key = "xxx"

}

resource "datadog_monitor" "dog-monitor" {
  name       = "test-dog-monitor"
  type       = "metric alert"
  message    = "Monitor triggered. Notify: redhawkmail@gmail.com"
  query      = "sum(last_5m):avg:datadog.agent.started{http-server} by {host}.as_count() < 1"
  depends_on = [google_compute_instance.datadog_instance]
}
