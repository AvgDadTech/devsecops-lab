resource "azurerm_resource_group" "devsecops_lab" {
  name     = "rg-devsecops-lab"
  location = "Central US"

  tags = {
    Project     = "DevSecOps-Lab"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Purpose     = "Learning"
  }
}

resource "azurerm_log_analytics_workspace" "devsecops_lab" {
  name                = "workspace-rgdevsecopslabuuWA"
  location            = azurerm_resource_group.devsecops_lab.location
  resource_group_name = azurerm_resource_group.devsecops_lab.name

  tags = {
    Project     = "DevSecOps-Lab"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Purpose     = "Learning"
  }
}
resource "azurerm_container_app_environment" "devsecops_lab" {
  name                = "cae-devsecops-lab"
  location            = azurerm_resource_group.devsecops_lab.location
  resource_group_name = azurerm_resource_group.devsecops_lab.name

  log_analytics_workspace_id = azurerm_log_analytics_workspace.devsecops_lab.id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    minimum_count         = 0
    maximum_count         = 0
  }

  tags = {
    Project     = "DevSecOps-Lab"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Purpose     = "Learning"
  }
}
resource "azurerm_container_app" "first_app" {
  name                         = "ca-first-app"
  container_app_environment_id = azurerm_container_app_environment.devsecops_lab.id
  resource_group_name          = azurerm_resource_group.devsecops_lab.name
  revision_mode                = "Single"

  workload_profile_name  = "Consumption"
  max_inactive_revisions = 100

  template {
    min_replicas = 0
    max_replicas = 10

    container {
      name   = "ca-first-app"
      image  = "ghcr.io/avgdadtech/devsecops-lab:88a26db17503910bd7eda33b960432a1248f3209"
      cpu    = 0.5
      memory = "1Gi"

      liveness_probe {
        transport               = "HTTP"
        port                    = 5000
        path                    = "/health"
        initial_delay           = 10
        interval_seconds        = 10
        timeout                 = 5
        failure_count_threshold = 3
      }

      readiness_probe {
        transport               = "HTTP"
        port                    = 5000
        path                    = "/health"
        initial_delay           = 3
        interval_seconds        = 5
        timeout                 = 5
        failure_count_threshold = 3
        success_count_threshold = 1
      }

      startup_probe {
        transport               = "TCP"
        port                    = 5000
        initial_delay           = 1
        interval_seconds        = 1
        timeout                 = 3
        failure_count_threshold = 240
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 5000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = {
    Project     = "DevSecOps-Lab"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Purpose     = "Learning"
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }
}