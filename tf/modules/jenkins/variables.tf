variable "prefix" {}
variable "domain" {}
variable "region" {}
variable "log_group_name" {}
variable "docker_image" {}

variable "data_volume" {
  default = "/data"
}

variable "cluster_id" {}

variable "subnets" {
  type = "list"
}

variable "vpc_id" {}
variable "zone_id" {}
variable "loadbalancer_arn" {}
variable "loadbalancer_fqdn" {}
variable "loadbalancer_zone_id" {}
variable "loadbalancer_listener_arn" {}
variable "service_number" {}
