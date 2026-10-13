terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstatebb80595d7e"
    container_name       = "tfstate"
    key                  = "devsecops-lab.tfstate"

    use_azuread_auth = true
    use_cli          = true
  }
}