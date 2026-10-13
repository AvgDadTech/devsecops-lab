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
resource "azurerm_application_insights" "devsecops_lab" {
  name                = "ai-devsecops-lab"
  location            = azurerm_resource_group.devsecops_lab.location
  resource_group_name = azurerm_resource_group.devsecops_lab.name
  application_type    = "web"

  workspace_id        = azurerm_log_analytics_workspace.devsecops_lab.id
  sampling_percentage = 0

  tags = {
    Project     = "DevSecOps-Lab"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Purpose     = "Learning"
  }
}
resource "azurerm_application_insights_standard_web_test" "first_app_health" {
  name                    = "ca-first-app-health-ai-devsecops-lab"
  resource_group_name     = azurerm_resource_group.devsecops_lab.name
  location                = azurerm_resource_group.devsecops_lab.location
  application_insights_id = azurerm_application_insights.devsecops_lab.id

  geo_locations = [
    "us-va-ash-azr",
    "us-il-ch1-azr",
    "us-tx-sn1-azr",
    "us-fl-mia-edge",
    "us-ca-sjc-azr"
  ]

  frequency     = 300
  timeout       = 30
  enabled       = true
  retry_enabled = true

  request {
    url                              = "https://ca-first-app.prouddesert-8684aaa4.centralus.azurecontainerapps.io/health"
    http_verb                        = "GET"
    follow_redirects_enabled         = false
    parse_dependent_requests_enabled = false
  }

  validation_rules {
    expected_status_code        = 200
    ssl_check_enabled           = true
    ssl_cert_remaining_lifetime = 7
  }
}
# Sends notifications when Azure Monitor alerts fire.
resource "azurerm_monitor_action_group" "devsecops_lab" {
  name                = "ag-devsecops-lab"
  resource_group_name = azurerm_resource_group.devsecops_lab.name
  short_name          = "DevSecOpsLab"
  enabled             = true

  email_receiver {
    name                    = "Email-Cody_-EmailAction-"
    email_address           = "cody@foundrylabsllc.com"
    use_common_alert_schema = false
  }
}
# Alert when our application fails availability checks
resource "azurerm_monitor_metric_alert" "first_app_health" {
  name                = "ca-first-app-health-ai-devsecops-lab"
  resource_group_name = azurerm_resource_group.devsecops_lab.name

  description   = "Automatically created alert rule for availability test \"ca-first-app-health-ai-devsecops-lab\""
  auto_mitigate = false

  scopes = [
    azurerm_application_insights_standard_web_test.first_app_health.id,
    azurerm_application_insights.devsecops_lab.id
  ]

  severity    = 1
  enabled     = true
  frequency   = "PT1M"
  window_size = "PT5M"

  application_insights_web_test_location_availability_criteria {
    web_test_id           = azurerm_application_insights_standard_web_test.first_app_health.id
    component_id          = azurerm_application_insights.devsecops_lab.id
    failed_location_count = 2
  }

  action {
    action_group_id = azurerm_monitor_action_group.devsecops_lab.id
  }
  lifecycle {
    ignore_changes = [
      scopes,
      tags,
      action,
      application_insights_web_test_location_availability_criteria
    ]
  }
}
# Monitor unexpected Azure Container App restarts
resource "azurerm_monitor_metric_alert" "container_restarts" {
  name                = "Total Restarts"
  resource_group_name = azurerm_resource_group.devsecops_lab.name

  scopes = [
    azurerm_container_app.first_app.id
  ]

  severity      = 0
  enabled       = true
  auto_mitigate = true
  frequency     = "PT5M"
  window_size   = "PT5M"

  target_resource_type     = "Microsoft.App/containerApps"
  target_resource_location = "centralus"

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "RestartCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }
}