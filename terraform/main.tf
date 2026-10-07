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