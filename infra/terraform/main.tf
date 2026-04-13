terraform {
  required_version = ">= 1.14.8"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "local" {}

# Create a directory for generated artifacts
resource "local_file" "app_config" {
  filename = "${path.module}/generated/${var.app_name}-${var.environment}.env"

  content = <<-EOT
    APP_NAME= "myapp"
    ENVIRONMENT= "dev"
    API_BASE_URL= "http://myapp-dev.local"
    LOG_LEVEL= "INFO"
  EOT
}
