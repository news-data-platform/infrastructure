variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-north-1"
}

variable "aws_availability_zone" {
  description = "AWS availability zone to deploy to"
  type        = string
  default     = "eu-north-1a"
}

variable "project_name" {
  description = "Short name prefix for all resources"
  type        = string
  default     = "news-data-platform"
}

variable "enabled" {
  description = "Turn on/off resources"
  type        = bool
  default     = true
}
