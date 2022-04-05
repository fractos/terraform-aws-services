module "service_list_task" {
  source = "git::https://github.com/fractos/terraform-aws-modules.git//tf/modules/services/tasks/base/?ref=v2.1"

  environment_variables = {
    "AWS_DEFAULT_REGION" = var.region
  }

  environment_variables_length = 1

  prefix           = var.prefix
  log_group_name   = var.log_group_name
  log_group_region = var.region
  log_prefix       = "${var.prefix}-service-list"

  family = "${var.prefix}-service-list"

  container_name = "${var.prefix}-service-list"
  container_port = "80"

  cpu_reservation    = 0
  memory_reservation = 32

  docker_image = var.docker_image
}

module "service_list" {
  source = "git::https://github.com/fractos/terraform-aws-modules.git//tf/modules/services/base/web/?ref=v2.1"

  name       = "${var.prefix}-service-list"
  project    = var.project
  cluster_id = var.cluster_id

  subnets = [
    var.subnets,
  ]

  vpc = var.vpc_id

  task_definition_arn = module.service_list_task.task_definition_arn

  container_port       = "80"
  container_name       = "${var.prefix}-service-list"
  health_check_path    = "/ping"
  health_check_matcher = "200"

  hostname = "services"
  domain   = var.domain
  zone_id  = var.zone_id

  load_balancer_arn                = var.loadbalancer_arn
  load_balancer_fqdn               = var.loadbalancer_fqdn
  load_balancer_zone_id            = var.loadbalancer_zone_id
  load_balancer_https_listener_arn = var.loadbalancer_listener_arn
  service_number_https             = var.service_number
}
