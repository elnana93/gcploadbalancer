
#the configuration file for the terraform

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.25.0"
    }
  }
}

provider "google" {
  # Configuration options

  project     = "class5-416923"
  credentials = "class5-416923-759a04e64c63.json"
  zone        = "europe-southwest1-a" #us-central1-a,b,c,f
  region      = "europe-southwest1"   # Choose a suitable Europe region
}




output "instance_group" {
  value = google_compute_region_instance_group_manager.example_group.instance_group
}

output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.example_forwarding_rule.ip_address
}



