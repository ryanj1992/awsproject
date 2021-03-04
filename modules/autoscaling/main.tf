locals {
  ecs_cluster = var.environment == "us-east-1" ? "nginx-hello-world-us" : "nginx-hello-world-eu"
  ecs_service = var.environment == "us-east-1" ? "nginx-hello-world-us" : "nginx-hello-world-eu"
}


resource "aws_appautoscaling_target" "ecs_autoscaling" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${local.ecs_cluster}/${local.ecs_service}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_policy" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_autoscaling.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_autoscaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_autoscaling.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "memory_policy" {
  name               = "memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_autoscaling.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_autoscaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_autoscaling.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}