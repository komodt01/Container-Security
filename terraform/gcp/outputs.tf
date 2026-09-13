output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "artifact_registry_repository" {
  description = "Artifact Registry Docker repository path"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}
