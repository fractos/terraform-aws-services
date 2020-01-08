data "aws_iam_policy_document" "jenkins" {
  statement {
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy" "ecr_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy" "jenkins_ecs" {
  role   = module.jenkins_task.role_name
  policy = data.aws_iam_policy_document.jenkins.json
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_power_user" {
  role       = module.jenkins_task.role_name
  policy_arn = data.aws_iam_policy.ecr_power_user.arn
}
