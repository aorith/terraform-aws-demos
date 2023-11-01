resource "aws_ecs_cluster" "default" {
  name = local.name

  tags = local.default_tags
}

resource "aws_ecs_service" "cidr" {
  name                               = local.container_name
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.cidr.arn # The task that our service will run
  launch_type                        = "FARGATE"
  desired_count                      = 1   # Maximum number of containers deployed
  deployment_maximum_percent         = 200 # Maximum overprovisioning
  deployment_minimum_healthy_percent = 0   # Minimum (set to 100 to avoid downtime)

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = aws_ecs_task_definition.cidr.family
    container_port   = local.container_port
  }

  network_configuration {
    subnets = [for subnet in aws_subnet.private : subnet.id]
    # Must be enabled for tasks in public subnets and disabled for tasks
    # in private subnets + NAT
    assign_public_ip = false
    security_groups  = [aws_security_group.cidr_sg.id]
  }

  depends_on = [aws_lb.default, aws_db_instance.default]

  tags = local.default_tags
}

resource "aws_ecs_task_definition" "cidr" {
  family = "${local.container_name}-0" # Unique name for the task definition
  container_definitions = jsonencode([
    {
      "name" : "${local.container_name}-0",
      "image" : "${local.container_image}",
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : local.container_port,
          "hostPort" : local.container_port
        }
      ],
      "cpu" : 512,
      "memory" : 1024,
      "environment" : [
        { "name" : "DB_USERNAME", "value" : data.sops_file.cidr_env.data.db_username },
        { "name" : "DB_PASSWORD", "value" : data.sops_file.cidr_env.data.db_password },
        { "name" : "DB_HOST", "value" : "${aws_db_instance.default.address}" },
        { "name" : "DB_PORT", "value" : tostring(local.db_port) },
        { "name" : "DB_NAME", "value" : "${local.db_name}" },
        { "name" : "JWT_SECRET", "value" : data.sops_file.cidr_env.data.jwt_secret },
        { "name" : "DEFAULT_ADMIN_USER", "value" : data.sops_file.cidr_env.data.default_admin_user },
        { "name" : "DEFAULT_ADMIN_USER_PASSWORD", "value" : data.sops_file.cidr_env.data.default_admin_user_password }
      ],
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # Required for FARGATE
  cpu                      = 512
  memory                   = 1024

  # ARN of a role that the ECS container agent / docker can assume
  #execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  tags = local.default_tags
}
