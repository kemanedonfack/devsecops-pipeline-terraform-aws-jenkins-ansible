resource "aws_ecs_cluster" "ecs_cluster" {
  name = "EC2-Cluster"
  tags = {
    Name = "ecs_cluster"

  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "app-first-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "app-first-task",
      "image": "${aws_ecr_repository.ecr.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8090,
          "hostPort": 8090
        }
      ],
      "memory": 2048,
      "cpu": 1024,
      "environment": [
        {
          "name": "DB_HOST",
          "value": "${aws_db_instance.rds_master.endpoint}"
        },
        {
          "name": "DB_NAME",
          "value": "${aws_db_instance.rds_master.db_name}"
        },
        {
          "name": "DB_USERNAME",
          "value": "${aws_db_instance.rds_master.username}"
        },
        {
          "name": "DB_PASSWORD",
          "value": "${aws_db_instance.rds_master.password}"
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 2048        # Specify the memory the container requires
  cpu                      = 1024        # Specify the CPU the container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "assiduite-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = aws_ecs_task_definition.ecs_task_definition.family
    container_port   = 8090
  }

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1_ecs.id, aws_subnet.public_subnet_2_ecs.id]
    assign_public_ip = true                                                # Provide the containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Set up the security group
  }
  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [eu-north-1b, eu-north-1c]"
  # }
}