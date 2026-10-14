# Architecture Decision Records

**Project:** DevSecOps Lab  
**Document Type:** Architecture Decision Records (ADRs)  
**Status:** Implemented architecture  
**Last reviewed:** October 2026

---

## Purpose

This document records the principal architectural decisions reflected in the DevSecOps Lab implementation.

Each decision describes:

- The engineering problem or requirement
- The selected approach
- The reasoning behind that approach
- Relevant alternatives
- Benefits and limitations
- Potential future improvements

The purpose is to make the system's design understandable, maintainable, and open to technical review.

### Documentation Scope

These records describe the implemented architecture and its engineering rationale.

Alternative technologies are discussed for comparison. Unless explicitly stated, their inclusion does not mean they were formally tested or benchmarked during the project.

---

# ADR-001: Use Ubuntu Linux as the Development Environment

**Status:** Implemented  
**Category:** Development Infrastructure

## Context

The project required an environment capable of running development tools, container tooling, infrastructure automation, and cloud administration utilities.

The environment needed to support:

- Python application development
- Git and GitHub integration
- Docker container operations
- Terraform
- Azure CLI
- VS Code
- Shell-based administration

## Decision

Use Ubuntu Linux installed directly on an HP workstation.

The workstation was configured with a dual-boot operating system setup.

## Rationale

Ubuntu provides a Linux environment suitable for development and infrastructure administration.

Running Ubuntu directly on the hardware allows the workstation to operate without depending on a separate Linux virtual machine.

It also provides practical experience working with Linux commands, filesystems, permissions, networking, and development tools.

## Alternatives

| Alternative | Consideration |
|---|---|
| Windows with WSL2 | Provides a Linux environment within Windows |
| macOS | Supports most required development tools |
| Linux virtual machine | Provides isolation from the host operating system |
| Cloud development workstation | Reduces dependence on local hardware |

These alternatives were not formally benchmarked.

## Consequences

### Benefits

- Native Linux development environment
- Direct access to common infrastructure tooling
- Practical Linux administration experience
- Local Docker and Terraform workflows

### Limitations

- Requires maintaining the workstation operating system
- Local configuration may differ from GitHub Actions runners
- Dual-boot configuration adds workstation maintenance complexity

## Future Considerations

Document exact operating system and tool versions.

Consider automating workstation configuration for reproducibility.

---

# ADR-002: Use Python Flask for the Application

**Status:** Implemented  
**Category:** Application Architecture

## Context

The project required an application that could be containerized, tested, deployed, and monitored.

The primary objective was to develop and validate the delivery infrastructure rather than build a complex business application.

## Decision

Implement a lightweight Python Flask application.

Use Gunicorn as the application server.

Expose application and health-check endpoints.

## Rationale

Flask provides a relatively small application surface while supporting the HTTP functionality needed to exercise the deployment pipeline.

This allows the project to focus on:

- Containerization
- Automated testing
- Dependency management
- Deployment automation
- Health monitoring
- Infrastructure operations

## Alternatives

| Alternative | Consideration |
|---|---|
| FastAPI | Modern Python framework with additional API-oriented features |
| Django | More comprehensive application framework |
| Node.js / Express | JavaScript-based application runtime |
| Go HTTP service | Compiled application with different runtime characteristics |

No framework performance comparison was conducted.

## Consequences

### Benefits

- Small application codebase
- Straightforward containerization
- Compatible with Python security tooling
- Simple health-check implementation

### Limitations

- Limited application complexity
- Does not demonstrate advanced authentication or authorization
- Does not represent a complete production business application

## Future Considerations

Apply the same delivery architecture to a more complex application with real operational requirements.

---

# ADR-003: Package the Application Using Docker

**Status:** Implemented  
**Category:** Application Delivery

## Context

The application needed to run consistently between local development, automated builds, and cloud hosting.

Managing dependencies directly on each environment would increase configuration differences.

## Decision

Package the Python application and its dependencies into a Docker container image.

## Rationale

Containerization provides a defined runtime environment and supports deployment to managed container platforms.

The same image can be scanned, published, and deployed.

## Alternatives

| Alternative | Consideration |
|---|---|
| Direct deployment to a virtual machine | Requires operating system and runtime management |
| Azure App Service code deployment | Managed hosting without requiring a custom container |
| Serverless functions | Suitable for event-driven workloads with different execution requirements |

## Consequences

### Benefits

- Consistent application packaging
- Portable deployment artifact
- Integration with container security scanning
- Compatible with Azure Container Apps

### Limitations

- Container images require vulnerability management
- Base images and dependencies must be maintained
- Containerization does not eliminate application security risks

## Future Considerations

Improve image hardening, dependency management, and artifact provenance.

---

# ADR-004: Use GitHub Actions for CI/CD

**Status:** Implemented  
**Category:** Delivery Automation

## Context

The project required an automated workflow for validating source changes and deploying approved application builds.

Manual deployment would create unnecessary repetition and increase the risk of inconsistent execution.

## Decision

Use GitHub Actions for continuous integration and continuous deployment.

## Rationale

GitHub Actions integrates with the project's source repository and supports the required development workflow.

The implemented pipeline performs:

1. Secret scanning
2. Static application security testing
3. Dependency vulnerability scanning
4. Automated application testing
5. Docker image building
6. Container vulnerability scanning
7. Container image publishing
8. Azure authentication
9. Application deployment

## Alternatives

| Alternative | Consideration |
|---|---|
| Azure DevOps Pipelines | Strong integration with Azure services |
| GitLab CI/CD | Integrated source control and pipeline platform |
| Jenkins | Flexible self-managed automation |
| Manual deployment | Lower initial automation effort but greater operational repetition |

## Consequences

### Benefits

- Automated validation
- Repeatable deployment process
- Repository-integrated workflow history
- Reduced manual deployment effort
- Support for federated Azure authentication

### Limitations

- Workflow security depends on permissions and action dependencies
- Third-party actions introduce supply-chain considerations
- The current implementation uses a single job for validation and deployment

## Future Considerations

Separate validation and deployment into distinct jobs.

Apply least-privilege permissions to each job.

Pin third-party actions to reviewed commit SHAs.

---

# ADR-005: Integrate Security Checks Into CI/CD

**Status:** Implemented  
**Category:** DevSecOps

## Context

Application delivery introduces risks involving exposed credentials, vulnerable dependencies, insecure code, and vulnerable container images.

These risks should be evaluated before publishing and deploying an application artifact.

## Decision

Integrate multiple automated security checks into the CI/CD workflow.

### Implemented Tools

| Tool | Security Function |
|---|---|
| Gitleaks | Secret detection |
| Semgrep | Static application security testing |
| pip-audit | Python dependency vulnerability scanning |
| Trivy | Container image vulnerability scanning |

## Rationale

The tools address different categories of security risk.

Using multiple tools provides broader coverage than relying on a single scanner.

The checks are executed automatically during CI.

## Consequences

### Benefits

- Security feedback during development
- Automated detection of selected vulnerability classes
- Reduced reliance on manual scanning
- Failed checks can prevent subsequent deployment steps

### Limitations

- Scanners can produce false positives and false negatives
- Detection depends on rules and vulnerability databases
- Passing scans does not prove that an application is secure
- Trivy is configured to ignore vulnerabilities without available fixes

## Future Considerations

- Expand static analysis coverage
- Review scanner configurations regularly
- Introduce documented vulnerability exception procedures
- Evaluate SBOM generation
- Consider artifact signing and provenance verification

---

# ADR-006: Use GitHub Container Registry

**Status:** Implemented  
**Category:** Artifact Management

## Context

The CI/CD pipeline required a registry for storing container images before deployment.

Images needed to be accessible to the Azure deployment process.

## Decision

Use GitHub Container Registry (GHCR).

Publish images using Git commit SHA tags.

## Rationale

GHCR integrates with GitHub Actions and provides a centralized location for container artifacts.

Commit-specific tags establish a traceable relationship between source code and published images.

## Alternatives

| Alternative | Consideration |
|---|---|
| Azure Container Registry | Native Azure container registry service |
| Docker Hub | Widely supported public container registry |
| Amazon ECR | AWS-integrated registry |

## Consequences

### Benefits

- GitHub-integrated authentication
- Centralized image storage
- Commit-based artifact identification
- Supports deployment to Azure Container Apps

### Limitations

- Registry availability is an external dependency
- Git tags alone do not guarantee artifact immutability
- The deployment architecture does not currently enforce signed-image verification

## Future Considerations

Evaluate immutable image digests and artifact provenance verification.

---

# ADR-007: Use Azure Container Apps Instead of Managing Kubernetes

**Status:** Implemented  
**Category:** Cloud Runtime

## Context

The project required a cloud platform capable of hosting a containerized HTTP application.

The application did not require a complex orchestration platform.

## Decision

Deploy the application using Azure Container Apps.

## Rationale

Azure Container Apps provides managed container hosting with:

- HTTPS ingress
- Health probes
- Container revisions
- Autoscaling
- Integration with Azure monitoring services

This allows the project to focus on application delivery and infrastructure automation without managing a Kubernetes cluster.

## Alternatives

| Alternative | Consideration |
|---|---|
| Azure Kubernetes Service | Greater orchestration flexibility and operational complexity |
| Azure App Service | Managed application hosting |
| Azure Virtual Machines | More direct operating system control |
| AWS ECS/Fargate | Managed container hosting in AWS |

## Consequences

### Benefits

- Reduced infrastructure administration
- Managed container execution
- Built-in scaling capabilities
- Integration with Azure services

### Limitations

- Less direct control over the underlying orchestration platform
- Azure-specific configuration
- Platform limits and managed-service dependencies

## Future Considerations

Evaluate Kubernetes when workload requirements justify the additional operational complexity.

Kubernetes is not required merely to make the project more sophisticated.

---

# ADR-008: Use OIDC Federation for Azure Deployment Authentication

**Status:** Implemented  
**Category:** Identity and Access Management

## Context

GitHub Actions required permission to update Azure Container Apps.

A deployment workflow needs to authenticate to Azure without exposing unnecessary credentials.

## Decision

Use Microsoft Entra ID workload identity federation with GitHub Actions OIDC.

## Rationale

OIDC allows GitHub Actions to exchange a short-lived identity token for Azure access without storing a long-lived Azure client secret.

The deployment identity is authorized through Azure RBAC.

## Implemented Authorization

The deployment service principal has Contributor access scoped to the application resource group.

## Alternatives

| Alternative | Consideration |
|---|---|
| Azure client secret | Simpler initial setup but introduces secret rotation and storage requirements |
| Certificate-based authentication | Avoids shared client secrets but requires certificate lifecycle management |
| Managed identity | Useful for supported workloads running within Azure |

## Consequences

### Benefits

- No long-lived Azure client secret required in GitHub
- Federated authentication
- Centralized Azure authorization
- Resource-group-scoped permissions

### Limitations

- Federated identity configuration must be maintained
- Incorrect trust conditions can create security exposure
- Contributor permissions remain broad within the assigned resource group

## Future Considerations

Evaluate a custom role with only the permissions required for deployment.

Review repository and branch trust conditions periodically.

---

# ADR-009: Manage Azure Infrastructure With Terraform

**Status:** Implemented  
**Category:** Infrastructure as Code

## Context

The project required a maintainable representation of Azure infrastructure.

Manually configured resources are more difficult to reproduce and compare against an intended configuration.

## Decision

Use Terraform with the AzureRM provider.

Import existing application infrastructure into Terraform state and reconcile the configuration.

## Rationale

Terraform supports:

- Declarative infrastructure definitions
- Execution planning
- Resource lifecycle management
- State-based infrastructure tracking
- Version-controlled configuration

## Alternatives

| Alternative | Consideration |
|---|---|
| Azure Portal | Useful for exploration but less reproducible |
| Azure CLI scripts | Scriptable but requires explicit lifecycle logic |
| Bicep | Azure-native declarative infrastructure |
| Pulumi | Infrastructure defined using general-purpose programming languages |

## Consequences

### Benefits

- Version-controlled infrastructure
- Reviewable execution plans
- Resource dependency management
- Repeatable infrastructure management

### Limitations

- State requires secure storage and maintenance
- Provider behavior may differ from Azure API representations
- Terraform configuration can drift from externally modified resources
- Imported infrastructure may require careful reconciliation

## Future Considerations

Improve drift detection and reduce lifecycle ignore rules where practical.

Introduce automated Terraform planning with appropriately restricted credentials.

---

# ADR-010: Store Terraform State in Azure Blob Storage

**Status:** Implemented  
**Category:** Infrastructure State Management

## Context

Terraform requires state to track managed infrastructure.

Keeping the only state copy on a local workstation creates risks involving data loss, inconsistent state, and recovery.

## Decision

Migrate Terraform state to an Azure Blob Storage backend.

Use Microsoft Entra ID authentication for backend access.

Maintain the backend separately from the application resource group.

## Rationale

Remote state provides centralized storage and supports state recovery and controlled access.

Separating the backend from application resources allows application infrastructure to be destroyed without simultaneously deleting its state.

## Implemented Controls

- Microsoft Entra ID authentication
- Azure RBAC access
- HTTPS-only access
- Minimum TLS 1.2
- Shared key access disabled
- Public blob access disabled
- Blob versioning
- Blob soft-delete retention
- Container soft-delete retention

## Alternatives

| Alternative | Consideration |
|---|---|
| Local Terraform state | Simple but tied to the workstation |
| Terraform Cloud / HCP Terraform | Managed state and workflow capabilities |
| Other supported remote backends | Depend on organizational infrastructure and requirements |

## Consequences

### Benefits

- State stored independently from the workstation
- Azure identity-based access
- Versioning and recovery capabilities
- Separation from application infrastructure

### Limitations

- Storage account requires ongoing management
- Backend resources may incur costs
- Remote state can contain sensitive infrastructure information
- Deleting the backend prematurely can complicate cleanup and recovery

## Future Considerations

Review state access regularly.

Document state recovery procedures.

Remove the backend only after infrastructure teardown and final verification.

---

# ADR-011: Separate Infrastructure Provisioning From Application Deployment

**Status:** Implemented  
**Category:** Deployment Architecture

## Context

Terraform manages infrastructure configuration.

GitHub Actions deploys updated application container images.

If both systems attempt to control the deployed image, they can create conflicting desired states.

## Decision

Use Terraform to manage infrastructure resources and GitHub Actions to manage application image deployment.

Configure Terraform to ignore changes to the Container App image property.

## Rationale

This establishes separate responsibilities:

**Terraform**

- Infrastructure provisioning
- Resource configuration
- Infrastructure lifecycle

**GitHub Actions**

- Application validation
- Container image creation
- Security scanning
- Artifact publishing
- Application image deployment

## Consequences

### Benefits

- Reduces deployment conflicts
- Separates infrastructure changes from application releases
- Supports independent application deployment

### Limitations

- Terraform does not enforce the deployed image version
- Image configuration changes made outside CI/CD may not be detected by Terraform
- Ownership boundaries must be maintained consistently

## Future Considerations

Document the authoritative source for each configuration property.

Consider deployment verification and drift detection outside Terraform for the application image.

---

# ADR-012: Use Azure-Native Monitoring

**Status:** Implemented  
**Category:** Observability

## Context

The application required basic health monitoring and visibility into operational failures.

The monitoring solution needed to integrate with Azure Container Apps.

## Decision

Use Azure Application Insights, Log Analytics, and Azure Monitor.

## Implemented Capabilities

- Public health endpoint
- Container health probes
- Availability testing
- Availability metric alert
- Container restart metric alert
- Email action group for availability notifications

## Rationale

Azure-native monitoring provides managed capabilities without deploying and operating a separate monitoring stack.

## Alternatives

| Alternative | Consideration |
|---|---|
| Prometheus and Grafana | Flexible metrics collection and visualization |
| Datadog | Commercial observability platform |
| Self-hosted monitoring | Greater control with additional operational responsibility |

## Consequences

### Benefits

- Integration with Azure resources
- Managed availability testing
- Configurable alerting
- Reduced monitoring infrastructure overhead

### Limitations

- Monitoring services can incur additional costs
- Alert configuration requires testing and maintenance
- Restart alert notification delivery is not configured
- Comprehensive application tracing has not been established

## Future Considerations

- Test alert notification delivery
- Improve restart alert routing
- Add structured application logs
- Define service-level indicators
- Evaluate monitoring costs and retention settings

---

# ADR-013: Use Scale-to-Zero for the Lab Environment

**Status:** Implemented  
**Category:** Cost Management

## Context

The application is a learning environment rather than a continuously utilized production service.

Running unnecessary compute resources would increase cloud costs.

## Decision

Configure Azure Container Apps with a minimum replica count of zero.

## Rationale

Scale-to-zero can reduce compute consumption during periods of inactivity.

This is appropriate for a low-traffic lab application.

## Consequences

### Benefits

- Reduced idle compute consumption
- Supports temporary lab usage
- No requirement to maintain a continuously running application replica

### Limitations

- Requests may experience cold-start latency
- Other Azure services may continue generating charges
- Availability checks may periodically cause the application to become active
- Scale-to-zero does not guarantee zero cloud costs

## Future Considerations

Destroy temporary infrastructure when no longer required.

Maintain the Terraform configuration in GitHub for future reconstruction.

---

# ADR-014: Keep the Lab Scope Intentionally Limited

**Status:** Implemented  
**Category:** Engineering Scope

## Context

DevSecOps encompasses many technologies and practices.

Attempting to implement every possible tool would increase complexity without necessarily improving the project's educational value.

## Decision

Focus on a complete, working application delivery lifecycle rather than introducing additional infrastructure solely for complexity.

## Rationale

The project demonstrates:

- Linux development
- Application containerization
- Automated testing
- Security scanning
- CI/CD
- Container artifact management
- Federated cloud authentication
- Infrastructure as code
- Remote state management
- Cloud deployment
- Health monitoring
- Operational troubleshooting

These components form a practical foundation for larger systems.

## Consequences

### Benefits

- Manageable infrastructure complexity
- Clear architectural boundaries
- Lower cloud costs
- Easier troubleshooting
- Focus on completing and validating the delivery lifecycle

### Limitations

The project does not demonstrate:

- Kubernetes cluster administration
- Complex distributed application architecture
- Multi-region disaster recovery
- Advanced application identity systems
- Production-scale performance engineering

## Future Considerations

Apply the established practices to applications with more complex requirements before introducing additional infrastructure technologies.

---

# Decision Summary

| ADR | Decision | Primary Benefit |
|---|---|---|
| 001 | Ubuntu Linux workstation | Native Linux development |
| 002 | Python Flask | Lightweight application target |
| 003 | Docker | Consistent application packaging |
| 004 | GitHub Actions | Automated delivery |
| 005 | Automated security scanning | Earlier security feedback |
| 006 | GitHub Container Registry | Centralized image storage |
| 007 | Azure Container Apps | Managed container hosting |
| 008 | OIDC federation | Reduced credential exposure |
| 009 | Terraform | Version-controlled infrastructure |
| 010 | Azure Blob remote state | Centralized infrastructure state |
| 011 | Separate infrastructure and application delivery | Reduced configuration conflicts |
| 012 | Azure-native monitoring | Managed operational visibility |
| 013 | Scale-to-zero | Reduced idle compute consumption |
| 014 | Limited project scope | Focused implementation and validation |

---

# Engineering Review

The implemented architecture favors managed services, automation, reproducibility, and reduced operational overhead.

These choices are appropriate for the scope of the lab.

However, several decisions introduce trade-offs that would require reconsideration in a production environment.

The most significant areas are:

1. GitHub Actions job permissions
2. Third-party action dependency management
3. Deployment rollback verification
4. Terraform drift suppression
5. Monitoring coverage and alert testing
6. Recovery procedures
7. Cloud cost management

The architecture should be evaluated against the requirements of each future application rather than adopted unchanged.

---

# Related Documentation

- [Project Overview](../README.md)
- [System Architecture](architecture.md)
- [Security Architecture](security.md)
- [Operational Runbook](operations.md)
- [Development Workstation](workstation-setup.md)
