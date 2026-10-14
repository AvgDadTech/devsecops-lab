# Operational Runbook

**Project:** DevSecOps Lab  
**Environment:** Microsoft Azure — Central US  
**Application:** Python Flask / Azure Container Apps  
**Infrastructure:** Terraform  
**Status:** Deployment validated; rollback and disaster recovery not tested

---

## 1. Purpose

This runbook documents the procedures required to operate, troubleshoot, recover, and decommission the DevSecOps Lab.

The intended audience is an engineer familiar with Git, Linux, containers, Terraform, and basic Azure administration.

The environment is a learning and portfolio system, not a production service.

### Operational Principles

1. Prefer automated deployment over manual changes.
2. Review Terraform plans before applying infrastructure changes.
3. Preserve Terraform state until managed resources are successfully destroyed.
4. Use short-lived authentication rather than persistent deployment secrets.
5. Verify application health after deployment.
6. Record failures and corrective actions.
7. Never assume that stopping application compute eliminates all cloud charges.

---

## 2. Environment Inventory

| Component | Identifier |
|---|---|
| GitHub repository | `AvgDadTech/devsecops-lab` |
| Azure region | `centralus` |
| Application resource group | `rg-devsecops-lab` |
| Container App | `ca-first-app` |
| Container Apps environment | `cae-devsecops-lab` |
| Application Insights | `ai-devsecops-lab` |
| Log Analytics | `workspace-rgdevsecopslabuuWA` |
| Terraform backend resource group | `rg-terraform-state` |
| Terraform storage account | `sttfstatebb80595d7e` |
| Terraform state container | `tfstate` |
| Terraform state key | `devsecops-lab.tfstate` |

### Application URL

```text
https://ca-first-app.prouddesert-8684aaa4.centralus.azurecontainerapps.io/
```

Health endpoint:

```text
https://ca-first-app.prouddesert-8684aaa4.centralus.azurecontainerapps.io/health
```

These URLs are valid only while the corresponding infrastructure exists.

---

## 3. Local Administration Requirements

The engineering workstation requires:

- Git
- Azure CLI
- Terraform
- Docker
- Python
- Access to the GitHub repository
- Appropriate Azure permissions

The original development environment is an HP workstation running Ubuntu Linux.

The application does not depend on this workstation remaining online.

### Authenticate to Azure

```bash
az login
```

Confirm the active subscription:

```bash
az account show --query "{name:name,id:id}" -o table
```

Verify the intended subscription before making changes.

### Navigate to Terraform

```bash
cd ~/projects/devsecops-lab/terraform
```

Initialize Terraform:

```bash
terraform init
```

This initializes the configured remote backend and provider dependencies.

---

## 4. Application Deployment

### Standard Deployment

Application deployment is automated through GitHub Actions.

Workflow:

```text
.github/workflows/ci.yml
```

The pipeline performs:

1. Secret scanning
2. Static application analysis
3. Dependency vulnerability scanning
4. Automated tests
5. Docker image build
6. Container vulnerability scanning
7. GHCR image publishing
8. Azure OIDC authentication
9. Azure Container Apps deployment

Publishing and deployment occur only on pushes to `main`.

### Deployment Procedure

1. Commit application changes.
2. Push changes to the authorized branch.
3. Open GitHub Actions.
4. Review the CI workflow execution.
5. Confirm that all required steps succeed.
6. Verify the deployed application health endpoint.

### Deployment Verification

```bash
curl -i https://ca-first-app.prouddesert-8684aaa4.centralus.azurecontainerapps.io/health
```

Expected result:

```text
HTTP/2 200
```

The exact HTTP protocol version may differ.

A successful HTTP 200 response confirms that the health endpoint responded successfully at the time of the request.

It does not prove that all application functionality is healthy.

---

## 5. Azure Container App Operations

### Check Application Status

```bash
az containerapp show --name ca-first-app --resource-group rg-devsecops-lab --query "{name:name,provisioningState:properties.provisioningState,latestRevision:properties.latestRevisionName}" -o json
```

### List Application Revisions

```bash
az containerapp revision list --name ca-first-app --resource-group rg-devsecops-lab -o table
```

### View Application Logs

```bash
az containerapp logs show --name ca-first-app --resource-group rg-devsecops-lab --type console --tail 100
```

### View Container App Configuration

```bash
az containerapp show --name ca-first-app --resource-group rg-devsecops-lab -o json
```

Review output before sharing it publicly because resource configurations may contain operationally sensitive details.

---

## 6. Troubleshooting

### Scenario A: GitHub Actions Fails

Open the failed workflow run in GitHub Actions.

Identify the first failed step.

| Failed Stage | Investigation |
|---|---|
| Gitleaks | Review potential exposed credentials |
| Semgrep | Review flagged source code |
| pip-audit | Inspect dependency vulnerability findings |
| Pytest | Review failing assertions and application behavior |
| Docker build | Check Dockerfile and build dependencies |
| Trivy | Review detected image vulnerabilities |
| GHCR publishing | Check package permissions and registry authentication |
| Azure OIDC | Check federation configuration and identity permissions |
| Azure deployment | Inspect Azure CLI errors and Container App state |

Do not bypass security checks solely to obtain a successful deployment.

### Scenario B: Application Returns an Error

Check the health endpoint:

```bash
curl -i https://ca-first-app.prouddesert-8684aaa4.centralus.azurecontainerapps.io/health
```

Inspect application logs:

```bash
az containerapp logs show --name ca-first-app --resource-group rg-devsecops-lab --type console --tail 100
```

Inspect the current revision:

```bash
az containerapp revision list --name ca-first-app --resource-group rg-devsecops-lab -o table
```

Determine whether the failure relates to:

- Application startup
- Container configuration
- Health probes
- Image availability
- Application code
- Resource limits

### Scenario C: Terraform Plan Shows Unexpected Changes

Run:

```bash
terraform plan
```

Review all proposed actions.

Pay particular attention to:

- Resource replacement
- Resource deletion
- Identity and access changes
- Container App configuration
- Monitoring changes
- Terraform lifecycle exclusions

Do not apply unexpected changes without understanding their impact.

---

## 7. Monitoring

### Availability Monitoring

Application Insights is configured to test the application's `/health` endpoint every five minutes from five geographic locations.

The availability alert evaluates failed test locations.

An action group is configured with an email notification destination.

### Container Restart Monitoring

Azure Monitor includes a restart metric alert.

The alert is configured to trigger when the restart count exceeds zero.

The restart alert does not currently have a notification action group configured.

### Operational Limitations

The existence of alert resources does not prove that every notification path has been tested.

Alert delivery and incident escalation should be validated before relying on this configuration for production workloads.

---

## 8. Application Rollback

**Status: Procedure documented; live rollback not tested.**

The Container App uses single-revision mode.

A previous image may be redeployed if a known-good image remains available in GHCR.

### Proposed Rollback Procedure

1. Identify the last known-good Git commit.
2. Verify that its container image exists in GHCR.
3. Review the image and the reason for rollback.
4. Confirm that the deployment identity has the necessary permissions.
5. Update the Container App to the selected image.
6. Verify the application health endpoint.
7. Inspect logs and monitoring results.
8. Record the rollback and follow-up actions.

Example command:

```bash
az containerapp update --name ca-first-app --resource-group rg-devsecops-lab --image ghcr.io/avgdadtech/devsecops-lab:<known-good-commit-sha>
```

Replace the placeholder with a verified image tag.

This command changes the deployed application and must not be executed without selecting and validating the intended image.

### Important Consideration

The standard GitHub Actions workflow deploys the image associated with the latest authorized push to `main`.

A subsequent deployment may replace a manually rolled-back image.

The rollback process therefore requires coordination with the source repository and deployment workflow.

---

## 9. Terraform Infrastructure Operations

### Validate Configuration

```bash
terraform fmt -check
```

```bash
terraform validate
```

### Review Infrastructure Changes

```bash
terraform plan
```

The plan should be reviewed before applying any changes.

### Apply Approved Changes

```bash
terraform apply
```

Only execute after reviewing and approving the intended plan.

For higher assurance, save a plan file and apply that exact reviewed plan.

### Terraform State

List managed resources:

```bash
terraform state list
```

The project previously managed nine Azure resources.

State must be treated as operationally sensitive information.

Do not commit Terraform state files to GitHub.

---

## 10. Infrastructure Recovery

**Status: Recovery procedure documented; complete reconstruction not tested.**

Terraform configuration is retained in GitHub.

Reconstruction requires:

- An Azure subscription
- Appropriate Azure permissions
- Terraform
- Azure CLI
- Valid provider configuration
- A correctly configured Terraform backend
- Access to the required container image

### Recovery Considerations

The original infrastructure was imported into Terraform after initial Azure resource creation.

Therefore, the existing configuration has not been fully validated through a clean deployment into an empty environment.

Before attempting reconstruction:

1. Verify the Terraform backend configuration.
2. Determine whether existing state should be recovered or replaced.
3. Verify Azure permissions.
4. Confirm resource names and availability.
5. Review resource dependencies.
6. Run Terraform validation.
7. Generate and inspect an execution plan.
8. Apply only the approved changes.
9. Deploy an application image.
10. Verify health and monitoring.

Do not assume that recreating infrastructure alone will automatically restore the latest application version.

The GitHub Actions workflow manages application image deployment separately from Terraform.

---

## 11. Cost Management

### Cost Characteristics

Azure Container Apps is configured with a minimum replica count of zero.

This can reduce idle compute consumption.

However, additional services may incur costs, including:

- Monitoring
- Log ingestion and retention
- Storage
- Availability testing
- Other provisioned Azure resources

Stopping the application does not guarantee zero Azure charges.

### Cost Reduction Strategy

For an inactive learning environment, deleting unnecessary infrastructure is generally more effective than simply stopping application compute.

The GitHub repository and Terraform configuration can be retained without keeping the Azure application resources deployed.

---

## 12. Infrastructure Decommissioning

**WARNING: The procedures in this section delete Azure resources.**

Do not execute destructive commands until the intended resources have been reviewed.

### Phase 1: Preserve Project Assets

Before deleting infrastructure:

1. Confirm source code is committed to GitHub.
2. Confirm Terraform configuration is committed.
3. Confirm architecture and security documentation is committed.
4. Capture deployment evidence.
5. Capture Terraform validation evidence.
6. Verify the remote state backend is accessible.
7. Identify any resources not managed by Terraform.

### Phase 2: Review Destruction Plan

Navigate to the Terraform directory:

```bash
cd ~/projects/devsecops-lab/terraform
```

Authenticate to Azure:

```bash
az login
```

Initialize Terraform:

```bash
terraform init
```

Generate the destruction plan:

```bash
terraform plan -destroy
```

Review every resource scheduled for deletion.

The expected application infrastructure consists of nine Terraform-managed resources in the application resource group.

Do not proceed if the plan includes unexpected resources.

### Phase 3: Destroy Application Infrastructure

After reviewing and approving the plan:

```bash
terraform destroy
```

Terraform will request confirmation before proceeding.

This operation deletes the managed application infrastructure.

The separate Terraform state backend is not included in the application's Terraform configuration.

### Phase 4: Verify Resource Removal

Check the application resource group:

```bash
az group show --name rg-devsecops-lab
```

If the resource group was successfully deleted, Azure should report that it does not exist.

Also inspect the subscription for any remaining lab-related resources.

Resources created outside Terraform may require separate cleanup.

### Phase 5: Clean Up Terraform Backend

The Terraform backend resides in:

`rg-terraform-state`

It contains the storage account:

`sttfstatebb80595d7e`

Do not delete this backend until:

- Terraform destruction has completed successfully.
- No application resources remain that depend on the state.
- No other Terraform configurations use the backend.
- Any required state backup has been preserved.

Deleting the backend is a separate administrative operation.

If the backend resource group is dedicated exclusively to this lab and is no longer needed, it may be deleted after verification.

### Phase 6: Verify Billing

Review Azure Cost Management.

Confirm that no unintended resources remain.

Billing data may take time to reflect recently deleted resources.

Infrastructure deletion stops future usage of the deleted resources, but previously incurred charges may still appear.

---

## 13. Post-Decommissioning Behavior

After the application infrastructure is deleted:

- The public application endpoint will no longer function.
- Azure availability monitoring will no longer operate.
- GitHub source code remains available.
- Terraform configuration remains available.
- Existing GHCR images may remain available.
- GitHub Actions workflow definitions remain in the repository.

### Important CI/CD Consideration

The current CI/CD workflow automatically attempts deployment on pushes to `main`.

After Azure infrastructure is destroyed, future pushes to `main` may trigger deployment attempts against resources that no longer exist.

These runs may fail until infrastructure is restored or the deployment workflow is intentionally disabled or modified.

This behavior must be addressed during decommissioning.

---

## 14. Operational Validation Record

| Capability | Status |
|---|---|
| Automated CI/CD deployment | Verified |
| Application health endpoint | Verified |
| Azure OIDC authentication | Verified |
| Terraform remote state | Verified |
| Terraform no-change plan | Verified |
| Monitoring resources configured | Verified |
| Live alert notification delivery | Not comprehensively tested |
| Application rollback | Not tested |
| Clean infrastructure reconstruction | Not tested |
| Complete disaster recovery | Not tested |
| Final infrastructure teardown | Pending |

---

## 15. Known Operational Limitations

The current implementation has several limitations:

1. No formally tested rollback procedure.
2. No complete disaster recovery exercise.
3. No production service-level objectives.
4. No formal incident escalation process.
5. Incomplete validation of alert notification delivery.
6. No automated post-deployment health verification in CI/CD.
7. No automated infrastructure destruction workflow.
8. Some Terraform monitoring properties are excluded from drift detection.
9. CI/CD deployment depends on the continued existence of the Azure application infrastructure.

These limitations are documented intentionally.

---

## Related Documentation

- [Project Overview](../README.md)
- [System Architecture](architecture.md)
- [Architecture Decisions](decisions.md)
- [Security Architecture](security.md)
- [Development Workstation](workstation-setup.md)

---

## Conclusion

The DevSecOps Lab has a validated automated deployment workflow and version-controlled infrastructure configuration.

This runbook establishes the procedures required to operate, investigate, recover, and decommission the environment.

Some recovery and incident response procedures remain documented but untested.

The project should not be represented as production-ready without additional validation and operational hardening.
