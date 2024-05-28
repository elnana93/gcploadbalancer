#health check
resource "google_compute_health_check" "example" {
  name                = "example-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 3
  unhealthy_threshold = 2

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

#Backend Service
resource "google_compute_backend_service" "example_backend_service" {
  name          = "example-backend-service"
  port_name     = "http"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.example.self_link]
  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_region_instance_group_manager.example_group.instance_group
  }
}


#URL Map for lb
resource "google_compute_url_map" "example_url_map" {
  name            = "example-url-map"
  default_service = google_compute_backend_service.example_backend_service.self_link

}

resource "google_compute_target_http_proxy" "example_http_proxy" {
  name    = "example-http-proxy"
  url_map = google_compute_url_map.example_url_map.self_link
}


resource "google_compute_global_forwarding_rule" "example_forwarding_rule" {
  name       = "example-forwarding-rule"
  target     = google_compute_target_http_proxy.example_http_proxy.self_link
  port_range = "80"
}

#firewall rule
resource "google_compute_firewall" "default" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
    
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
  
}