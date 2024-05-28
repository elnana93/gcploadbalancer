

#vpc

# Define the VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

# Define subnets in different zones
resource "google_compute_subnetwork" "subnet_a" {
  name          = "subnet-a"
  ip_cidr_range = "10.50.1.0/24"
  region        = "europe-southwest1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = "subnet-b"
  ip_cidr_range = "10.50.2.0/24"
  region        = "europe-southwest1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "subnet_c" {
  name          = "subnet-c"
  ip_cidr_range = "10.50.3.0/24"
  region        = "europe-southwest1"
  network       = google_compute_network.vpc_network.self_link
}