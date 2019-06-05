module "jenkins_task" {
  source = "git::https://github.com/digirati-co-uk/terraform-aws-modules.git//tf/modules/services/tasks/base/"

  environment_variables = {
    "JAVA_OPTS" = "-Dhudson.footerURL=jenkins.${var.domain} -Djava.util.logging.config.file=/var/jenkins_home/log.properties"
  }

  environment_variables_length = 1

  prefix           = "${var.prefix}"
  log_group_name   = "${var.log_group_name}"
  log_group_region = "${var.region}"
  log_prefix       = "${var.prefix}-jenkins"

  family = "${var.prefix}-jenkins"

  container_name = "${var.prefix}-jenkins"
  container_port = "8080"

  cpu_reservation    = 0
  memory_reservation = 128

  docker_image = "${var.docker_image}"

  mount_points = [
    {
      sourceVolume  = "${var.prefix}-jenkins"
      containerPath = "/var/jenkins_home"
    },
    {
      sourceVolume  = "${var.prefix}-docker"
      containerPath = "/var/run/docker.sock"
    },
  ]
}

resource "aws_ecs_task_definition" "jenkins_task" {
  family                = "${var.prefix}-jenkins"
  container_definitions = "${module.jenkins_task.task_definition_json}"
  task_role_arn         = "${module.jenkins_task.role_arn}"

  volume {
    name      = "${var.prefix}-jenkins"
    host_path = "${var.data_volume}/${var.prefix}-jenkins/data"
  }

  volume {
    name      = "${var.prefix}-docker"
    host_path = "/var/run/docker.sock"
  }
}

module "jenkins" {
  source = "git::https://github.com/digirati-co-uk/terraform-aws-modules.git//tf/modules/services/base/web/"

  name       = "${var.prefix}-jenkins"
  project    = "${var.project}"
  cluster_id = "${var.cluster_id}"

  subnets = [
    "${var.subnets}",
  ]

  vpc = "${var.vpc_id}"

  container_port       = "8080"
  container_name       = "${var.prefix}-jenkins"
  task_definition_arn  = "${aws_ecs_task_definition.jenkins_task.arn}"
  health_check_path    = "/login"
  health_check_matcher = "200"

  health_check_grace_period_seconds = "600"

  hostname                         = "jenkins"
  domain                           = "${var.domain}"
  zone_id                          = "${var.zone_id}"
  load_balancer_arn                = "${var.loadbalancer_arn}"
  load_balancer_fqdn               = "${var.loadbalancer_fqdn}"
  load_balancer_zone_id            = "${var.loadbalancer_zone_id}"
  load_balancer_https_listener_arn = "${var.loadbalancer_listener_arn}"
  service_number_https             = "${var.service_number}"
}
