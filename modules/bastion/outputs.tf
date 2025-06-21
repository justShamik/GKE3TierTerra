output "bastion_nat_ip" {
  description = "Public IP of the bastion host"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}