provider "google" {
  credentials = file("/home/user/terraform-admin.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_instance" "zabbix-server" {
  name         = "zabbix-server"
  machine_type = var.machine_type

  tags = ["http-server"]
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
      type  = var.type
    }
  }
  metadata = {
    ssh-keys = "redhawkby:${file("~/.ssh/id_rsa.pub")}"

  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      host        = google_compute_instance.zabbix-server.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "./sh"
    destination = "/tmp/sh"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      host        = google_compute_instance.zabbix-server.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [

      #      "chmod +x /tmp/sh/*sh",
      #      "cd /tmp/sh",
      #      "./server.sh",


    ]
  }
}
resource "google_compute_instance" "zabbix-client" {
  name         = "zabbix-client"
  machine_type = var.machine_type

  #  tags = ["http-server"]
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
      type  = var.type
    }
  }
  metadata = {
    ssh-keys = "redhawkby:${file("~/.ssh/id_rsa.pub")}"

  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      host        = google_compute_instance.zabbix-client.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "./sh"
    destination = "/tmp/sh"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      host        = google_compute_instance.zabbix-client.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      #  "echo ${google_compute_instance.zabbix-client.network_interface.0.network_ip}:9200 > /tmp/ip.txt",
      #    "chmod +x /tmp/sh/*sh",
      #      "cd /tmp/sh",
      #  "./client.sh",


    ]
  }
}
output "URL" {
  value = "http://${google_compute_instance.zabbix-server.network_interface.0.access_config.0.nat_ip}"
}
