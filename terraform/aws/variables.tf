variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate used by the HTTPS listener"
  type        = string
}
