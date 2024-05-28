
#http Load Balancer with mananged instance group mig


#instance template

resource "google_compute_instance_template" "example_template" {
  name         = "example-template"
  machine_type = "e2-medium" #e2-medium

  disk {
    auto_delete  = true
    boot         = true
    source_image = "projects/debian-cloud/global/images/family/debian-10"
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet_a.self_link
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\necho \"Running startup script. . .\"\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"

  }

  tags = ["web", "http-server"]
  
}


#instance group manager
resource "google_compute_region_instance_group_manager" "example_group" {
  name               = "example-instance-group"
  region             = "europe-southwest1"
  base_instance_name = "example-instance"
  target_size        = 3
  version {
    instance_template = google_compute_instance_template.example_template.self_link
  }

  named_port {
    name = "http"
    port = 80
  }

  distribution_policy_zones = [
    "europe-southwest1-a",
    "europe-southwest1-c",
    "europe-southwest1-b"
  ]

  auto_healing_policies {
    health_check      = google_compute_health_check.example.self_link
    initial_delay_sec = 300
  }
  
}