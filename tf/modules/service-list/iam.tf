data "aws_iam_policy_document" "service_list" {
  statement {
    actions = [
      "ecs:ListClusters",
      "ecs:ListServices",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "service_list" {
  role   = module.service_list_task.role_name
  policy = data.aws_iam_policy_document.service_list.json
}
