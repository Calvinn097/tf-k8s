variable "instance_os"{
    type = string
    default = "ubuntu-2004-focal-v20210325"
}
terraform {
    required_providers{
        google = {
            source= "hashicorp/google"
            version = "3.11.0"
        }
    }
}


resource "google_compute_router" "nat-router-us-central1" {
  name    = "nat-router-us-central1"
  region  = "us-central1"
  network  = google_compute_network.kubernetes_network.name

}


resource "google_compute_router_nat" "nat-config1" {
  name                               = "nat-config1"
  router                             = "${google_compute_router.nat-router-us-central1.name}"
  region                             = "us-central1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
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

resource "google_compute_instance" "kubenode1" {
    desired_status = "RUNNING"
    name            = "kubenode1"
    machine_type    = "e2-medium"
    can_ip_forward = "true"
    tags            = ["kubernetes", "devops"]
    metadata = {
        startup-script = "sudo ufw disable"
    }
    
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
    desired_status = "RUNNING"
    name            = "kubenode2"
    machine_type    = "e2-medium"
    can_ip_forward = "true"
    tags            = ["kubernetes", "devops"]
    metadata = {
        startup-script = "sudo ufw disable"
    }
    
    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }

    network_interface {
        network = google_compute_network.kubernetes_network.name
        
    }
}

resource "google_compute_instance" "kubenode3" {
    desired_status = "RUNNING"
    name            = "kubenode3"
    machine_type    = "e2-medium"
    can_ip_forward = "true"
    tags            = ["kubernetes", "devops"]
    metadata = {
        startup-script = "sudo ufw disable"
    }
    
    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }

    network_interface {
        network = google_compute_network.kubernetes_network.name
        
    }
}

resource "google_compute_instance" "kubenode4" {
    desired_status = "RUNNING"
    name            = "kubenode4"
    machine_type    = "e2-medium"
    can_ip_forward = "true"
    tags            = ["kubernetes", "devops"]
    metadata={
        startup-script = "sudo ufw disable"
    }
    
    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }

    network_interface {
        network = google_compute_network.kubernetes_network.name
        
    }
}

resource "google_compute_instance" "ansible"{
    desired_status = "RUNNING"
    name = "ansible"
    machine_type = "e2-micro"
    tags = ["devops", "ansible"]

    boot_disk {
        initialize_params{
            image = var.instance_os
        }
    }
    
    network_interface{
        network = google_compute_network.kubernetes_network.name
        access_config{
            nat_ip = google_compute_address.ansible_static_ip.address
        }
    }
}


resource "google_compute_address" "vm_static_ip" {
    name="terraform-static-ip"
}

resource "google_compute_address" "vip_address"{
    name="kubernetes-vip"
}

resource "google_compute_address" "ansible_static_ip"{
    name = "ansible-static-ip"
}

resource "google_compute_firewall" "default"{
    name = "kubernetes-firewall"
    network = google_compute_network.kubernetes_network.name
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"

        # https://stackoverflow.com/questions/39293441/needed-ports-for-kubernetes-cluster
        ports = ["67-68","22","80", "443", "8080", "1000-2000", "6443",  "10250-10255", "30000-32767", "179", "2379-2380", "8081", "9254"]
    }

    allow {
        protocol = "udp"
        ports = ["8285", "8472", "22"]
    }

    source_tags = ["kubernetes", "devops"]
    source_ranges = ["0.0.0.0/0"]
}


output "vip_addr" {
    depends_on = [
        google_compute_address.vip_address
    ]
    value = google_compute_address.vip_address.address
    description = "The Public IP for load balancer"
    # sensitive = true
}

output "ansible_public_ip" {
    depends_on = [
        google_compute_address.ansible_static_ip
    ]
    value = google_compute_address.ansible_static_ip.address
    description = "The Public IP for ansible"
}

output "public_ip_kubenode1" {
    value = google_compute_instance.kubenode1.network_interface[0].access_config[0].nat_ip
}
output "public_ip_network_tier" {
    value = google_compute_instance.kubenode1.network_interface[0].access_config[0].network_tier
}

output "internal_ip_kubenode1"{
    value=google_compute_instance.kubenode1.network_interface[0].network_ip
}
output "internal_ip_kubenode2"{
    value=google_compute_instance.kubenode2.network_interface[0].network_ip
}
output "internal_ip_kubenode3"{
    value=google_compute_instance.kubenode3.network_interface[0].network_ip
}
output "internal_ip_kubenode4"{
    value=google_compute_instance.kubenode4.network_interface[0].network_ip
}
output "internal_ip_ansible" {
    value = google_compute_instance.ansible.network_interface[0].network_ip
}