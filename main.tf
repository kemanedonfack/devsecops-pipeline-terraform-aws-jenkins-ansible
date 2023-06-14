resource "aws_instance" "jenkins_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  key_name               = var.key_name
  user_data              = file("install_script_jenkins_instance.sh")
  iam_instance_profile   = aws_iam_instance_profile.s3_jenkins_instance_profile.name # access to s3 bucket

  tags = {
    Name = "jenkins"
  }
}

# resource "aws_instance" "sonarqube_server" {
#   ami                    = var.ami
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.public_subnet.id
#   vpc_security_group_ids = [aws_security_group.sonarqube-sg.id]
#   key_name               = var.key_name
#   user_data              = file("install_script_sonarqube.sh")

#   tags = {
#     Name = "Sonarqube"
#   }
# }

#Create S3 bucket for your application Artifacts not open to the public
resource "aws_s3_bucket" "jenkins_bucket" {
  bucket = "jenkins-bucket-${aws_instance.jenkins_instance.id}"
  tags = {
    description = "Private bucket to hold Jenkins artifacts"
    name        = "jenkins_bucket"
  }
}

