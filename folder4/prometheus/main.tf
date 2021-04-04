
provider "google" {
  project = var.project
  region  = var.region
}


resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  ip_cidr_range = "10.1.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}


resource "google_compute_firewall" "internal_all" {
  name    = "${var.name}-internal-fwr"
  network = google_compute_network.vpc.name
  allow {
    ports    = ["0-65535"]
    protocol = "tcp"
  }
  allow {
    ports    = ["0-65535"]
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.1.1.0/24"]
}

resource "google_compute_firewall" "external" {
  name    = "${var.name}-external-fwr"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80", "22", "3000", "9093", "9090", "9100", "9115"]
  }
  source_ranges = ["0.0.0.0/0"]
  description   = "rules for external connections, allows http and ssh"
}


resource "google_compute_address" "internal_server_address" {
  name         = "${var.name}-server-address"
  subnetwork   = google_compute_subnetwork.public.id
  address_type = "INTERNAL"
  region       = var.region
}


resource "google_compute_instance" "server" {
  depends_on   = [google_compute_instance.agent]
  name         = "${var.name}-server"
  zone         = var.zone
  machine_type = "n1-standard-1"
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
      type  = var.disk_type
    }
  }
  metadata_startup_script = templatefile("prometheus_provision.sh", { node_ip = "${google_compute_instance.agent.network_interface.0.network_ip}" })
  network_interface {
    network    = google_compute_network.vpc.name
    network_ip = google_compute_address.internal_server_address.address
    subnetwork = google_compute_subnetwork.public.name
    access_config {
    }
  }
}


resource "google_compute_instance" "agent" {
  name         = "${var.name}-agent"
  zone         = var.zone
  machine_type = "n1-standard-1"
  description  = "Centos 7 with installed tomcat"
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
      type  = var.disk_type
    }
  }
  metadata_startup_script = templatefile("node_exporter_provision.sh", { name = "${var.name}" })
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.public.name
    access_config {
    }
  }
}
