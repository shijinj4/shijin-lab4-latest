provider "google" {
  credentials = file("radiant-octane-405301-273377d383e6.json")
  project     = "radiant-octane-405301"
  region      = "us-central1"
  zone        = "us-central1-a"
}

resource "google_compute_network" "vpc" {
  name                    = "flask-app-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "flask-app-public-subnet"
  region        = "us-east1"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "flask-app-private-subnet"
  region        = "us-east1"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.2.0/24"
}

resource "google_compute_instance" "flask_app" {
  name         = "flask-app-instance"
  machine_type = "e2-medium"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.public_subnet.id
    access_config {
      // Empty block to assign a public IP address
    }
  }

  metadata = {
    gce-container-declaration = <<-EOT
spec:
  containers:
    - name: flask-app
      image: gcr.io/radiant-octane-405301/shijin-app:latest
      ports:
        - containerPort: 5000
  restartPolicy: Always
EOT
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "flask_app_fw" {
  name    = "flask-app-firewall"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_ranges = ["0.0.0.0/0"]
}
