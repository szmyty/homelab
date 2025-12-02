# Recommended GitHub Issues

This document contains a comprehensive list of recommended issues for the homelab repository.
Generated from analysis of the scaffolded repository structure.

---

## 1. Implement Pulumi Python/TypeScript Runtime [infra][pulumi]

**Description:**
The Pulumi configuration currently uses YAML runtime, which has limited functionality. Migrate to Python or TypeScript for better control, type safety, and advanced features like loops and conditionals.

**Checklist:**

- [ ] Create `__main__.py` or `index.ts` in `infra/pulumi/`
- [ ] Implement GCP resources programmatically
- [ ] Add proper error handling and validation
- [ ] Create separate modules for network, compute, and firewall resources
- [ ] Update documentation with new usage patterns

---

## 2. Add Ansible Playbooks for Server Configuration [infra][ansible]

**Description:**
The `infra/ansible/` directory only contains a README placeholder. Implement actual Ansible playbooks for server configuration management.

**Checklist:**

- [ ] Create `ansible.cfg` configuration file
- [ ] Create inventory templates for local and cloud hosts
- [ ] Implement `playbooks/docker-install.yml` for Docker setup
- [ ] Implement `playbooks/security-hardening.yml` for OS hardening
- [ ] Implement `playbooks/homelab-deploy.yml` for service deployment
- [ ] Create reusable roles for common tasks
- [ ] Add role for automated backups configuration

---

## 3. Implement Kubernetes Manifests with Kustomize [infra][k8s]

**Description:**
The `infra/k8s/` directory only contains a README placeholder. Implement Kubernetes manifests for all homelab services using Kustomize.

**Checklist:**

- [ ] Create base manifests for each service
- [ ] Implement Kustomize overlays for dev and prod environments
- [ ] Add ConfigMaps and Secrets templates
- [ ] Create PersistentVolumeClaim templates
- [ ] Add Ingress resources for Caddy replacement
- [ ] Create Helm chart alternative (optional)
- [ ] Document K8s deployment workflow

---

## 4. Create Syncthing Compose Bundle [services][infra]

**Description:**
Syncthing is defined as a service but is not included in any compose bundle. Add Syncthing to an appropriate bundle or create a new one.

**Checklist:**

- [ ] Decide bundle placement (core, utilities, or new bundle)
- [ ] Add Syncthing to compose bundle
- [ ] Update Caddy configuration in core bundle
- [ ] Update documentation

---

## 5. Standardize Caddy Reverse Proxy Snippets [services][networking]

**Description:**
Each service has its own Caddy configuration file, but they lack standardization. Create reusable Caddy snippets for common patterns.

**Checklist:**

- [ ] Create standard Caddy snippet template with security headers
- [ ] Add rate limiting snippet
- [ ] Add CORS configuration snippet
- [ ] Implement websocket upgrade handling (for Vaultwarden, Uptime Kuma)
- [ ] Add compression configuration
- [ ] Update all service Caddyfiles to use snippets
- [ ] Document Caddy customization options

---

## 6. Add Docker Compose Health Checks [infra][services]

**Description:**
Docker Compose files lack health check configurations. Add health checks to ensure services are running properly.

**Checklist:**

- [ ] Add healthcheck for Jellyfin (HTTP check on :8096)
- [ ] Add healthcheck for Vaultwarden (HTTP check on /alive)
- [ ] Add healthcheck for Paperless-ngx (HTTP check on /api)
- [ ] Add healthcheck for Uptime Kuma (HTTP check on /status)
- [ ] Add healthcheck for Caddy (HTTP check)
- [ ] Add healthcheck for database containers
- [ ] Update `check_health.sh` to use Docker healthcheck status

---

## 7. Implement Container Security Hardening [security][infra]

**Description:**
Containers lack security hardening options. Add security configurations to limit container capabilities.

**Checklist:**

- [ ] Add `read_only: true` for applicable containers
- [ ] Add `security_opt: no-new-privileges:true`
- [ ] Define resource limits (cpu, memory) for all containers
- [ ] Add `cap_drop: ALL` and explicit `cap_add` for required capabilities
- [ ] Add user namespace remapping configuration
- [ ] Document security configurations in SECURITY.md

---

## 8. Add Restore Functionality to Backup Script [scripts][backup]

**Description:**
The backup script supports backup operations but lacks restore functionality referenced in the documentation.

**Checklist:**

- [ ] Implement `--restore` flag for backup.sh
- [ ] Add volume restoration from tar archives
- [ ] Add database restoration functionality
- [ ] Implement backup verification before restore
- [ ] Add dry-run mode for restore operations
- [ ] Document restore procedures

---

## 9. Create CONTRIBUTING.md Guidelines [docs][DX]

**Description:**
The repository lacks contribution guidelines for external contributors.

**Checklist:**

- [ ] Create CONTRIBUTING.md in repository root
- [ ] Document development environment setup
- [ ] Define code style and linting requirements
- [ ] Add pull request template
- [ ] Add issue templates (bug report, feature request)
- [ ] Document commit message conventions
- [ ] Add code of conduct

---

## 10. Add Watchtower for Automatic Updates [services][automation]

**Description:**
Add Watchtower service for automatic Docker container updates with notification support.

**Checklist:**

- [ ] Create Watchtower service configuration
- [ ] Add to core.yml compose bundle
- [ ] Configure notification channels (email, webhook)
- [ ] Add label-based update control for services
- [ ] Configure update schedule
- [ ] Document Watchtower configuration

---

## 11. Implement Centralized Logging Stack [monitoring][infra]

**Description:**
Add centralized logging solution such as Loki/Promtail for aggregating container logs.

**Checklist:**

- [ ] Choose logging stack (Loki/Promtail recommended for simplicity)
- [ ] Create logging bundle compose file
- [ ] Configure log drivers for all services
- [ ] Add Grafana for log visualization
- [ ] Configure log retention policies
- [ ] Document logging architecture

---

## 12. Add Prometheus and Grafana Monitoring [monitoring][infra]

**Description:**
Enhance monitoring beyond Uptime Kuma with system and container metrics collection. Uptime Kuma provides availability monitoring, but lacks resource utilization metrics (CPU, memory, disk, network). Add Prometheus for metrics collection and Grafana for visualization dashboards.

**Checklist:**

- [ ] Create monitoring.yml compose bundle
- [ ] Add Prometheus with service discovery
- [ ] Add Grafana with pre-configured dashboards
- [ ] Add cAdvisor for container metrics
- [ ] Add Node Exporter for host metrics
- [ ] Create alerting rules
- [ ] Document monitoring setup

---

## 13. Create .env.example at Repository Root [DX][infra]

**Description:**
Add a root-level `.env.example` file for global environment variables used by compose bundles.

**Checklist:**

- [ ] Create root `.env.example` with common variables (TZ, PUID, PGID, DOMAIN)
- [ ] Update compose bundles to reference root `.env`
- [ ] Update bootstrap.sh to copy root env file
- [ ] Document environment variable hierarchy

---

## 14. Add Trivy Container Scanning to CI [security][CI]

**Description:**
Add container image vulnerability scanning using Trivy in GitHub Actions.

**Checklist:**

- [ ] Create new workflow `security-scan.yml`
- [ ] Scan base images used by services
- [ ] Configure severity thresholds
- [ ] Add SARIF output for GitHub Security tab
- [ ] Add scheduled weekly scans
- [ ] Document vulnerability response process

---

## 15. Implement Fail2ban Integration [security][services]

**Description:**
Add Fail2ban configuration for protecting exposed services from brute force attacks.

**Checklist:**

- [ ] Create Fail2ban service or configuration
- [ ] Add filters for Vaultwarden login attempts
- [ ] Add filters for SSH access
- [ ] Configure action rules (ban time, retries)
- [ ] Integrate with Caddy access logs
- [ ] Document Fail2ban configuration

---

## 16. Add YAML Linting Configuration [DX][CI]

**Description:**
Add `.yamllint.yml` configuration file to define YAML linting rules for the repository.

**Checklist:**

- [ ] Create `.yamllint.yml` with project-specific rules
- [ ] Configure line length limits
- [ ] Configure indentation rules
- [ ] Add exceptions for specific file patterns
- [ ] Test against all YAML files

---

## 17. Create Makefile for Common Tasks [DX][automation]

**Description:**
Add a Makefile to provide consistent commands for common development and deployment tasks.

**Checklist:**

- [ ] Create Makefile in repository root
- [ ] Add `make bootstrap` target
- [ ] Add `make deploy-local` target
- [ ] Add `make lint` target
- [ ] Add `make test` target
- [ ] Add `make backup` target
- [ ] Add `make clean` target
- [ ] Document Makefile usage

---

## 18. Add PostgreSQL Backup Automation for Paperless [backup][services]

**Description:**
Enhance backup script to properly handle PostgreSQL database backups for Paperless-ngx.

**Checklist:**

- [ ] Add `pg_dump` wrapper to backup script
- [ ] Implement automated database backup before volume backup
- [ ] Add backup rotation for database dumps
- [ ] Document database backup and restore procedures

---

## 19. Implement Secrets Management Solution [security][infra]

**Description:**
Consider implementing a secrets management solution beyond environment files.

**Checklist:**

- [ ] Evaluate options (SOPS, Vault, Docker secrets)
- [ ] Implement chosen solution
- [ ] Migrate sensitive values from env files
- [ ] Update documentation
- [ ] Add CI/CD integration for secrets

---

## 20. Add Docker Compose Profiles [infra][DX]

**Description:**
Implement Docker Compose profiles for flexible service deployment instead of separate bundle files.

**Checklist:**

- [ ] Create unified docker-compose.yml with profiles
- [ ] Define profiles: core, media, vault, docs, monitoring
- [ ] Update deploy_local.sh to support profiles
- [ ] Maintain backwards compatibility with bundles
- [ ] Document profile usage

---

## 21. Create Service Dependencies Graph [docs][services]

**Description:**
Add documentation showing service dependencies and network topology.

**Checklist:**

- [ ] Create visual diagram of service dependencies
- [ ] Document network requirements
- [ ] Add startup order documentation
- [ ] Include in ARCHITECTURE.md

---

## 22. Add Automated Testing for Scripts [testing][CI]

**Description:**
Add testing framework for shell scripts using BATS or similar.

**Checklist:**

- [ ] Choose testing framework (BATS recommended)
- [ ] Create test directory structure
- [ ] Add unit tests for bootstrap.sh
- [ ] Add unit tests for deploy_local.sh
- [ ] Add unit tests for backup.sh
- [ ] Integrate tests with GitHub Actions
- [ ] Document testing approach

---

## 23. Implement Cloudflare Tunnel Option [networking][infra]

**Description:**
Add Cloudflare Tunnel as an alternative to direct port exposure for secure remote access without port forwarding. This enables accessing homelab services from anywhere without exposing ports to the public internet.

**Checklist:**

- [ ] Create Cloudflare Tunnel service configuration
- [ ] Document Cloudflare setup process
- [ ] Create alternative compose bundle
- [ ] Update SECURITY.md with tunnel benefits

---

## 24. Add Dependabot Configuration [security][CI]

**Description:**
Configure Dependabot for automated dependency updates.

**Checklist:**

- [ ] Create `.github/dependabot.yml`
- [ ] Configure Docker image updates
- [ ] Configure GitHub Actions updates
- [ ] Configure Python dependency updates
- [ ] Set update schedule and reviewers

---

## 25. Create Migration Scripts [automation][infra]

**Description:**
Create scripts for migrating data and configuration between deployments.

**Checklist:**

- [ ] Create `migrate.sh` script
- [ ] Support volume migration between hosts
- [ ] Support configuration export/import
- [ ] Add validation checks
- [ ] Document migration procedures

---

## 26. Add VPN Configuration Templates [services][security]

**Description:**
Add configuration templates for various VPN providers for qBittorrent/Gluetun.

**Checklist:**

- [ ] Create templates for Mullvad, ProtonVPN, NordVPN
- [ ] Document WireGuard configuration
- [ ] Document OpenVPN configuration
- [ ] Add VPN connectivity testing

---

## 27. Implement SSL Certificate Monitoring [monitoring][security]

**Description:**
Add SSL certificate expiration monitoring to Uptime Kuma or dedicated service.

**Checklist:**

- [ ] Configure certificate monitoring in Uptime Kuma
- [ ] Set up expiration alerts
- [ ] Document certificate management
- [ ] Add Let's Encrypt renewal verification

---

## 28. Add Webhook Notifications for Alerts [monitoring][automation]

**Description:**
Implement webhook notifications for critical alerts from monitoring systems.

**Checklist:**

- [ ] Configure Discord/Slack webhook integration
- [ ] Set up Uptime Kuma notifications
- [ ] Configure backup failure notifications
- [ ] Document notification setup

---

## 29. Create Disaster Recovery Runbook [docs][backup]

**Description:**
Create detailed disaster recovery runbook with step-by-step procedures.

**Checklist:**

- [ ] Document RTO/RPO objectives
- [ ] Create step-by-step recovery procedures
- [ ] Add verification checklists
- [ ] Include contact/escalation information
- [ ] Schedule periodic DR tests

---

## 30. Add AWS/Azure Pulumi Stacks [infra][pulumi]

**Description:**
Extend Pulumi support to AWS and Azure providers as mentioned in documentation.

**Checklist:**

- [ ] Create AWS stack configuration
- [ ] Create Azure stack configuration
- [ ] Document provider-specific requirements
- [ ] Add cost estimation for each provider

---

## 31. Implement Automatic DNS Updates [networking][automation]

**Description:**
Add automatic DNS record updates when IP addresses change.

**Checklist:**

- [ ] Create DNS update script
- [ ] Support Cloudflare DNS API
- [ ] Support Google Cloud DNS
- [ ] Add to startup/cron automation
- [ ] Document DNS management

---

## 32. Add Minio for S3-Compatible Storage [services][backup]

**Description:**
Add Minio service for local S3-compatible object storage for backups and media.

**Checklist:**

- [ ] Create Minio service configuration
- [ ] Add to appropriate compose bundle
- [ ] Configure backup destination to Minio
- [ ] Document Minio usage and access

---

## 33. Create Service Health Dashboard [monitoring][services]

**Description:**
Create a dedicated health dashboard page using Uptime Kuma status page feature.

**Checklist:**

- [ ] Configure Uptime Kuma status page
- [ ] Add all services to monitoring
- [ ] Create public status page configuration
- [ ] Document status page access

---

## 34. Add Pre-flight Checks to Deploy Scripts [DX][automation]

**Description:**
Add pre-flight checks to deployment scripts to catch common issues.

**Checklist:**

- [ ] Check required environment variables
- [ ] Verify Docker connectivity
- [ ] Check port availability
- [ ] Verify volume paths exist
- [ ] Add network connectivity checks

---

## 35. Implement Log Rotation Configuration [infra][monitoring]

**Description:**
Configure Docker logging drivers with proper log rotation.

**Checklist:**

- [ ] Configure json-file log driver with rotation
- [ ] Set max size and max file limits
- [ ] Document logging configuration
- [ ] Add to compose templates

---

## 36. Add EditorConfig for Consistent Formatting [DX]

**Description:**
Add `.editorconfig` file for consistent code formatting across editors.

**Checklist:**

- [ ] Create `.editorconfig` in repository root
- [ ] Define indent style and size
- [ ] Define line endings
- [ ] Define charset settings
- [ ] Test with common editors

---

## 37. Create Development vs Production Configurations [infra][DX]

**Description:**
Clearly separate development and production configurations with appropriate defaults.

**Checklist:**

- [ ] Create `docker-compose.dev.yml` override file
- [ ] Add development-specific settings (debug logs, exposed ports)
- [ ] Update documentation
- [ ] Add environment-specific `.env` templates

---

## 38. Add Renovate Configuration as Dependabot Alternative [CI][automation]

**Description:**
Consider adding Renovate for more advanced dependency management.

**Checklist:**

- [ ] Create `renovate.json` configuration
- [ ] Configure Docker image updates
- [ ] Configure schedule and auto-merge rules
- [ ] Document Renovate vs Dependabot choice

---

## 39. Implement Service-Level README Files [docs][services]

**Description:**
Add README.md files to each service directory with service-specific documentation.

**Checklist:**

- [ ] Create README.md template for services
- [ ] Add README to each service directory
- [ ] Document service-specific configuration
- [ ] Include troubleshooting sections

---

## 40. Add Changelog Management [docs][DX]

**Description:**
Implement changelog management for tracking repository changes.

**Checklist:**

- [ ] Create CHANGELOG.md in repository root
- [ ] Define changelog format (Keep a Changelog)
- [ ] Add release tagging workflow
- [ ] Document versioning strategy
- [ ] Consider automated changelog generation

---

## 41. Validate Runtipi Manifest Generation [services][automation]

**Description:**
Test and validate the Runtipi manifest generation script with actual Runtipi installation.

**Checklist:**

- [ ] Test `generate_runtipi_manifests.py` execution
- [ ] Validate generated JSON against Runtipi schema
- [ ] Add schema validation to CI
- [ ] Document Runtipi integration workflow
- [ ] Add sample generated manifests to documentation

---

## 42. Add Network Policies and Segmentation [security][networking]

**Description:**
Implement Docker network segmentation to isolate services appropriately.

**Checklist:**

- [ ] Create separate networks (frontend, backend, database)
- [ ] Limit inter-service communication
- [ ] Document network architecture
- [ ] Update compose files with network assignments

---

## 43. Create ARM64 Compatibility Guide [docs][infra]

**Description:**
Document ARM64 (Raspberry Pi, Apple Silicon) compatibility for all services.

**Checklist:**

- [ ] Audit all images for ARM64 support
- [ ] Document alternative images where needed
- [ ] Create ARM64-specific compose override
- [ ] Add to ARCHITECTURE.md

---

## 44. Add CI/CD Badge and Status to README [docs][CI]

**Description:**
Add workflow status badges to README for visibility.

**Checklist:**

- [ ] Add lint workflow badge
- [ ] Add compose-validate workflow badge
- [ ] Add security-scan badge (when implemented)
- [ ] Document badge configuration

---

## 45. Implement Proper gitattributes File [DX]

**Description:**
Add `.gitattributes` file for consistent file handling across platforms.

**Checklist:**

- [ ] Create `.gitattributes` in repository root
- [ ] Configure line ending normalization
- [ ] Mark binary files appropriately
- [ ] Configure diff settings for specific files
