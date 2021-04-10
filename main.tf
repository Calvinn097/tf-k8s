variable "instance_os"{
    type = string
    default = "ubuntu-2004-focal-v20210325"
}
terraform {
    required_providers{
        google = {
            source= "hashicorp/google"
            version = "3.5.0"
        }
    }
}

provider "google"{
    credentials = file("/key/valued-base-310101-f49407bddcca.json")
    project = "valued-base-310101"
    region = "us-central1"
    zone="us-central1-a"
}

resource "google_compute_network" "kubernetes_network" {
    name="kubernetes-network"
}

resource "google_compute_instance" "vm_instance" {
    name            = "kubenode1"
    machine_type    = "e2-medium"
    tags            = ["kubernetes", "devops"]
    
    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }

    network_interface {
        network = google_compute_network.kubernetes_network.name
        access_config{
            nat_ip = google_compute_address.vm_static_ip.address
        }
        
    }
}
resource "google_compute_instance" "kubenode1" {
    name            = "kubenode1"
    machine_type    = "e2-medium"
    tags            = ["kubernetes", "devops"]
    
    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }

    network_interface {
        network = google_compute_network.kubernetes_network.name
        access_config{
            nat_ip = google_compute_address.vm_static_ip.address
        }
        
    }
}
resource "google_compute_instance" "kubenode2" {
    name            = "kubenode2"
    machine_type    = "e2-medium"
    tags            = ["kubernetes", "devops"]
    
    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }

    network_interface {
        network = google_compute_network.kubernetes_network.name
        access_config{
            nat_ip = google_compute_address.vm_static_ip.address
        }
        
    }
}

resource "google_compute_instance" "kubenode3" {
    name            = "kubenode3"
    machine_type    = "e2-medium"
    tags            = ["kubernetes", "devops"]
    
    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }

    network_interface {
        network = google_compute_network.kubernetes_network.name
        access_config{
            nat_ip = google_compute_address.vm_static_ip.address
        }
        
    }
}

resource "google_compute_instance" "kubenode4" {
    name            = "kubenode4"
    machine_type    = "e2-medium"
    tags            = ["kubernetes", "devops"]
    
    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }

    network_interface {
        network = google_compute_network.kubernetes_network.name
        access_config{
            nat_ip = google_compute_address.vm_static_ip.address
        }
        
    }
}


resource "google_compute_address" "vm_static_ip" {
    name="terraform-static-ip"
}

resource "google_compute_firewall" "default"{
    name = "kubernetes-firewall"
    network = google_compute_network.kubernetes_network.name
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"

        #https://stackoverflow.com/questions/39293441/needed-ports-for-kubernetes-cluster
        ports = ["80", "443", "8080", "1000-2000", "6443",  "10250-10255", "30000-32767", "179", "2379-2380"]
    }

    allow {
        protocol = "udp"
        ports = ["8285", "8472"]
    }

    source_tags = ["kubernetes"]
}