output "network_name" {
  description = "Created local Docker network name."
  value       = docker_network.task4.name
}