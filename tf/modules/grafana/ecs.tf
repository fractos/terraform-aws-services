module "grafana_task" {
  source = "git::https://github.com/fractos/terraform-aws-modules.git//tf/modules/services/tasks/base/?ref=v2.1"

  environment_variables = {}

  environment_variables_length = 0

  prefix           = var.prefix
  log_group_name   = var.log_group_name
  log_group_region = var.region
  log_prefix       = "${var.prefix}-grafana"

  family = "${var.prefix}-grafana"

  container_name = "${var.prefix}-grafana"
  container_port = "3000"

  cpu_reservation    = 0
  memory_reservation = 128

  docker_image = var.docker_image

  mount_points = [
    {
      sourceVolume  = "${var.prefix}-grafana"
      containerPath = "/var/lib/grafana"
    },
  ]

  user = "0"
}

resource "aws_ecs_task_definition" "grafana_task" {
  family                = "${var.prefix}-grafana"
  container_definitions = module.grafana_task.task_definition_json
  task_role_arn         = module.grafana_task.role_arn

  volume {
    name      = "${var.prefix}-grafana"
    host_path = "${var.data_volume}/${var.prefix}-grafana/data"
  }
}

module "grafana" {
  source = "git::https://github.com/fractos/terraform-aws-modules.git//tf/modules/services/base/web/?ref=v2.1"

  name       = "${var.prefix}-grafana"
  project    = var.project
  cluster_id = var.cluster_id

  subnets = [
    var.subnets,
  ]

  vpc = var.vpc_id

  container_port       = "3000"
  container_name       = "${var.prefix}-grafana"
  task_definition_arn  = "${aws_ecs_task_definition.grafana_task.arn}"
  health_check_path    = "/login"
  health_check_matcher = "200"

  hostname = "grafana"
  domain   = var.domain
  zone_id  = var.zone_id

  load_balancer_arn                = var.loadbalancer_arn
  load_balancer_fqdn               = var.loadbalancer_fqdn
  load_balancer_zone_id            = var.loadbalancer_zone_id
  load_balancer_https_listener_arn = var.loadbalancer_listener_arn
  service_number_https             = var.service_number
}
