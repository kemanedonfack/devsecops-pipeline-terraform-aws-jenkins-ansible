output "jenkins_public_ip" {
  value = aws_instance.jenkins_instance.public_ip
}

output "sonarqube_public_ip" {
  value = aws_instance.sonarqube_server.public_ip
}