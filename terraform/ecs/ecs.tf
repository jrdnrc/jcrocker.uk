locals {
  repository_url = "643602138710.dkr.ecr.eu-west-1.amazonaws.com/jcruk"
}

resource "aws_ecs_cluster" "jcr-cluster" {
  name  = "jcrockeruk-ecs-cluster"
}

resource "aws_ecs_service" "jcrockeruk" {
  name  = "jcrockeruk-ecs-service"
  cluster = aws_ecs_cluster.jcr-cluster.id
  
  deployment_minimum_healthy_percent = 1
  deployment_maximum_percent = 500

  task_definition = aws_ecs_task_definition.service.arn
  desired_count = 2
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.jcrockeruk.arn
    container_name   = "jcruk-app"
    container_port   = 80
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [
        aws_security_group.egress-all.id,
        aws_security_group.http.id,
    ]

    subnets = [
        aws_subnet.private.id,
    ]
}
}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.jcruk-task-execution-role.arn

  cpu = 512
  memory = 1024
  network_mode = "awsvpc"
  

  container_definitions = jsonencode([
    {
      name      = "jcruk-app"
      image     = "643602138710.dkr.ecr.eu-west-1.amazonaws.com/jcruk"
      essential = true
      portMappings = [
        {
          containerPort = 80
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region = "eu-west-1",
          awslogs-group = "/ecs/jcruk",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "jcruk" {
  name = "/ecs/jcruk"
}