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
