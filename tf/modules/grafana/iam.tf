data "aws_iam_policy_document" "grafana" {
  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "grafana" {
  role   = "${module.grafana_task.role_name}"
  policy = "${data.aws_iam_policy_document.grafana.json}"
}
