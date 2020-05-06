# This mentions the provider (GCP , AWS etc)
provider "google" {
  version = "3.5.0"

  credentials = file(var.credentials_file)

  project = var.project 
  region  = var.region
  zone    = var.zone 
}



# This creates the VPC network , default is auto 
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}


# This creates the VM instance with network interface and disk
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = var.machine_types[var.environment] 
  tags         = ["web", "dev"]

  provisioner "local-exec" {
    command = "echo ${google_compute_instance.vm_instance.name}:  ${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip} >> ip_address.txt"
  }


  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.vm_static_ip.address 
    }
  }
}

#This creates a static Ip address
resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}


