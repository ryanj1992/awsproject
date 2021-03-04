resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "nginx_hello_world"

  dashboard_body = <<EOF
  {
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "nginx-hello-world-us", "ClusterName", "nginx-hello-world-us" ]
                ],
                "region": "us-east-1",
                "title": "CPU Utilisation"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "MemoryUtilization", "ServiceName", "nginx-hello-world-us", "ClusterName", "nginx-hello-world-us" ]
                ],
                "region": "us-east-1"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/us-east-1-public-alb/7dd4b400bd2c5081" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "stat": "Sum",
                "period": 300
            }
        }
    ]
}
EOF
}