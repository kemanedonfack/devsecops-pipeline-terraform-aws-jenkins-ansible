output "public_ip" {
  value = aws_instance.jenkins_instance.public_ip
}

# print the DNS of load balancer
output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.application_loadbalancer.dns_name
}
