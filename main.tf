resource "aws_appautoscaling_target" "autoscaling_target" {
  max_capacity       = var.target_max_capacity
  min_capacity       = var.target_min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  role_arn           = aws_iam_role.autoscaling_role.arn
  scalable_dimension = var.scalable_dimension
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_out_policy" {
  name               = "${var.name}-ScaleOutPolicy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = var.step_scale_out_adjustment
    }
  }

  depends_on = [
    aws_appautoscaling_target.autoscaling_target
  ]
}

resource "aws_appautoscaling_policy" "scale_in_policy" {
  name               = "${var.name}-ScaleInPolicy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = var.step_scale_in_adjustment
    }
  }

  depends_on = [
    aws_appautoscaling_target.autoscaling_target
  ]
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.name} Service High CPU"
  alarm_description   = "Alarm to add capacity if CPU is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.scale_out_threshold
  statistic           = "Average"
  period              = 60
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  treat_missing_data  = "notBreaching"
  dimensions          = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  alarm_actions       = [
    aws_appautoscaling_policy.scale_out_policy.arn
  ]
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.name} Service Low CPU"
  alarm_description   = "Alarm to reduce capacity if container CPU is low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  threshold           = var.scale_in_threshold
  statistic           = "Average"
  period              = 60
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  treat_missing_data  = "notBreaching"
  dimensions          = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  alarm_actions       = [
    aws_appautoscaling_policy.scale_in_policy.arn
  ]
  tags                = var.tags
}
