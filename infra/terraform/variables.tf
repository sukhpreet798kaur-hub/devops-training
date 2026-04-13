variable "app_name" {
  type        = string
  description = "Application name for which config is generated."
  default     = "myapp"
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
  default     = "dev"
}

variable "api_base_url" {
  type        = string
  description = "Base URL for API calls."
  default     = "http://myapp-dev.local"
}

variable "log_level" {
  type        = string
  description = "Log level for the application."
  default     = "INFO"
}
