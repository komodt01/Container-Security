output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "artifact_registry_url" {
  value = google_artifact_registry_repository.repo.id
}
