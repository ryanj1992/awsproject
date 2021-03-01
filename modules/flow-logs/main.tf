locals {
  flow_log_name = var.environment == "us-east-1" ? "cw_flow_log_us" : "cw_flow_log_eu"
  flow_iam_role = var.environment == "us-east-1" ? "flow_iam_role_us" : "flow_iam_role_eu"
}


resource "aws_flow_log" "flow_log" {
  vpc_id                   = var.main_vpc
  traffic_type             = "ALL"
  log_destination          = aws_cloudwatch_log_group.flow_log_group.arn
  iam_role_arn             = aws_iam_role.flow_iam_role.arn
  max_aggregation_interval = 60

  tags = {
    Name = "${var.environment}_flow_logs"
  }
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = local.flow_log_name
}

resource "aws_iam_role" "flow_iam_role" {
  name = local.flow_iam_role

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_iam_role_policy" {
  name = "flow_iam_role_policy"
  role = aws_iam_role.flow_iam_role.id

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}