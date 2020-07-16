data "aws_iam_policy_document" "autoscaling_assume" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      identifiers = [
        "ecs.application-autoscaling.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "autoscaling_role" {
  name                 = "${var.name}-AutoScalingRole"
  assume_role_policy   = data.aws_iam_policy_document.autoscaling_assume.json
  permissions_boundary = var.permissions_boundary_arn
}

data "aws_iam_policy_document" "autoscaling_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]

    resources = [
      "arn:aws:ecs:*:*:service/${var.name}*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DeleteAlarms"
    ]

    resources = [
      "arn:aws:cloudwatch:*:*:alarm:${var.name}-*"
    ]
  }
}

resource "aws_iam_role_policy" "autoscaling_role_policy" {
  name   = "${var.name}-AutoScalingPolicy"
  policy = data.aws_iam_policy_document.autoscaling_role_policy.json
  role   = aws_iam_role.autoscaling_role.id
}
