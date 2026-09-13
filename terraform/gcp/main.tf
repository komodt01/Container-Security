provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ----------------------------
# Networking
# ----------------------------

resource "google_compute_network" "vpc_network" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "gke-subnet"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

# ----------------------------
# Artifact Registry
# ----------------------------

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "container-secure-repo"
  description   = "Artifact Registry for application container images"
  format        = "DOCKER"
}

# ----------------------------
# Secret Manager
# ----------------------------

resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-key"

  replication {
    auto {}
  }
}

# The secret value is intentionally not stored in Terraform.
# Populate the secret through an approved secrets-management
# process after the secret resource has been created.

# ----------------------------
# GKE Cluster
# ----------------------------

resource "google_container_cluster" "primary" {
  name     = "gke-standard-cluster"
  location = var.zone

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}

# ----------------------------
# GKE Node Pool
# ----------------------------

resource "google_container_node_pool" "primary_nodes" {
  name     = "primary-node-pool"
  cluster  = google_container_cluster.primary.name
  location = var.zone

  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
