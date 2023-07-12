#IAM policy for S3 access
resource "aws_iam_policy" "ec2_jenkins_policy" {
  name = "ec2_jenkins_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ecs:*",
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "ecr:*",
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

#Create IAM role for Jenkins EC2 to allow S3 read/write access
resource "aws_iam_role" "ec2_jenkins_role" {
  name = "ec2_jenkins_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#Attaches IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "ec2_jenkins_policy_attachment" {
  policy_arn = aws_iam_policy.ec2_jenkins_policy.arn
  role       = aws_iam_role.ec2_jenkins_role.name
}


#IAM instance profile for EC2 instance
resource "aws_iam_instance_profile" "ec2_jenkins_instance_profile" {
  name = "ec2_jenkins_instance_profile"
  role = aws_iam_role.ec2_jenkins_role.name
}

