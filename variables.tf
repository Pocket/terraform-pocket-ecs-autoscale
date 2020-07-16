variable "name" {
  description = "Resource name prefix"
  type        = string
}
variable "target_max_capacity" {
  description = "Autoscaling max capacity"
  type        = number
}
variable "target_min_capacity" {
  description = "Autoscaling min capacity"
  type        = number
}
variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}
variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
}
variable "scalable_dimension" {
  description = "Autoscaling target scalable dimension"
  type        = string
}
variable "step_scale_out_adjustment" {
  description = "Autoscaling scale out policy step adjustment"
  type        = number
}
variable "step_scale_in_adjustment" {
  description = "Autoscaling scale in policy step adjustment"
  type        = number
}
variable "scale_out_threshold" {
  description = "Autoscaling scale out alarm threshold"
  type        = number
}
variable "scale_in_threshold" {
  description = "Autoscaling scale in alarm threshold"
  type        = number
}
variable "permissions_boundary_arn" {
  description = "Service permissions boundary arn"
  type        = string
}
variable "tags" {
  description = "Service tags"
}
