resource "aws_instance" "jenkins_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.jenkins_public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  key_name               = var.key_name
  user_data              = file("install_script_jenkins_instance.sh")
  iam_instance_profile   = aws_iam_instance_profile.s3_jenkins_instance_profile.name # access to s3 bucket

  tags = {
    Name = "jenkins-EC2"
  }
}

#Create S3 bucket for your application Artifacts not open to the public
resource "aws_s3_bucket" "jenkins_bucket" {
  bucket = "jenkins-bucket-${aws_instance.jenkins_instance.id}"
  tags = {
    description = "Private bucket to hold Jenkins artifacts"
    name        = "jenkins_bucket"
  }
}

# resource "aws_db_subnet_group" "database_subnet" {
#   name       = "db subnet"
#   subnet_ids = [aws_subnet.database_private_subnet.id, aws_subnet.database_read_replica_private_subnet.id]
# }

# resource "aws_db_instance" "instance_db1" {
#   identifier             = "mysql-db1"
#   db_name                = "mydb"
#   allocated_storage      = 10
#   availability_zone      = var.availability_zone[2]
#   db_subnet_group_name   = aws_db_subnet_group.database_subnet.id
#   engine                 = "mysql"
#   engine_version         = "8.0.31"
#   instance_class         = "db.t3.micro"
#   multi_az               = false
#   username               = "username"
#   password               = "passwordusername"
#   skip_final_snapshot    = true
#   vpc_security_group_ids = [aws_security_group.database-sg.id]
# }

# resource "aws_db_instance" "instance_db2" {
#   identifier             = "mysql-db2"
#   db_name                = "mydb"
#   allocated_storage      = 10
#   availability_zone      = var.availability_zone[1]
#   db_subnet_group_name   = aws_db_subnet_group.database_subnet.id
#   engine                 = "mysql"
#   engine_version         = "8.0.31"
#   instance_class         = "db.t3.micro"
#   multi_az               = false
#   username               = "username"
#   password               = "passwordusername"
#   skip_final_snapshot    = true
#   vpc_security_group_ids = [aws_security_group.database-sg.id]
# }

