provider "google" {
  credentials = file("/home/user/terraform-admin.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_instance" "ldap-server" {
  name         = "ldap-server"
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
  #metadata_startup_script = file("./startup_server.sh")

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
      host        = google_compute_instance.ldap-server.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
    source      = "./ldif"
    destination = "/tmp/ldif"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      host        = google_compute_instance.ldap-server.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [

      "chmod +x /tmp/ldif/*sh",
      "cd /tmp/ldif",
      "./startup_server.sh",


    ]
  }
  #  metadata_startup_script = file("./ldif/startup_server.sh")
}
resource "google_compute_instance" "ldap-client" {
  name         = "ldap-client"
  machine_type = var.machine_type


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
  #metadata_startup_script = file("./ldif/startup_server.sh")

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      port        = var.ssh_port
      user        = var.ssh_user
      agent       = "false"
      host        = google_compute_instance.ldap-client.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "sudo yum -y install openldap-clients nss-pam-ldapd authconfig",
      "sudo authconfig --enableldap --enableldapauth --ldapserver=${google_compute_instance.ldap-server.network_interface.0.network_ip} --ldapbasedn='dc=devopsldab,dc=com' --enablemkhomedir --updateall",
      "getent passwd",


    ]
  }

}
