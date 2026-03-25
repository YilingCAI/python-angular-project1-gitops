# mypythonproject1-gitops

Professional GitOps delivery repository for mypythonproject1 on AWS EKS using Argo CD and Helm.

## Project Overview

This repository is the deployment source of truth for Kubernetes runtime state. It contains Argo CD application definitions, Helm chart templates, and environment-specific values for dev, staging, and production.

Application source code and image builds are handled in mypythonproject1. This repository is responsible for declarative deployment and reconciliation in cluster.

## Architecture Flow

GitHub Actions -> Git commit to GitOps values -> Argo CD sync -> EKS workloads

## Architecture Diagram

```text
App Repository CI (build/push image)
              |
              v
+-----------------------------------+
| GitOps Repository                 |
| environments/<env>/values.yaml    |
+----------------+------------------+
                 |
                 v
+-----------------------------------+
| Argo CD                            |
| App-of-Apps + environment apps     |
+----------------+------------------+
                 |
                 v
+-----------------------------------+
| EKS Cluster                        |
| - backend deployment/service       |
| - frontend deployment/service      |
| - ingress and autoscaling          |
+-----------------------------------+
```

## Repository Structure

| Path | Purpose |
|---|---|
| apps/ | Argo CD Application and App-of-Apps manifests |
| charts/mypythonproject1/ | Helm chart for backend and frontend workloads |
| environments/dev/ | Dev Helm values overrides |
| environments/staging/ | Staging Helm values overrides |
| environments/production/ | Production Helm values overrides |

## Argo CD Application Model

- apps/app-of-apps.yaml defines root orchestration.
- apps/dev, apps/staging, and apps/production define environment-specific Argo CD Applications.
- charts/mypythonproject1 contains reusable templates used across all environments.
- environments/<env>/values.yaml carries the only environment-specific runtime deltas.

## Deployment Workflow

```text
Application CI builds and pushes images to ECR
        -> updates image tag in environments/<env>/values.yaml
        -> pushes commit to this repository
        -> Argo CD detects drift from desired state
        -> syncs Helm release to target namespace
```

## Local Validation and Rendering

```bash
# Lint chart templates
helm lint charts/mypythonproject1

# Render manifests for each environment
helm template mypythonproject1 charts/mypythonproject1 -f environments/dev/values.yaml
helm template mypythonproject1 charts/mypythonproject1 -f environments/staging/values.yaml
helm template mypythonproject1 charts/mypythonproject1 -f environments/production/values.yaml
```

## Operating Model

- Dev and staging are typically auto-synced by Argo CD.
- Production should use manual approval and controlled sync windows.
- Rollback is done by reverting Git commits in this repository.

## Security and Governance

- No plaintext secrets are stored in this repository.
- Runtime secrets should be injected from a managed secret system.
- Protect production values with branch protection and required reviews.
- Enforce signed commits and least-privilege write access where possible.

## Bootstrap Argo CD (one-time)

```bash
argocd app create app-of-apps \
        --repo <gitops-repo-url> \
        --path apps \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace argocd
```

## Tech Stack

- Argo CD
- Helm
- Kubernetes (EKS)
- GitHub Actions
- AWS ECR

## Future Improvements

- Add Helm unit and policy tests in CI before values changes merge.
- Add environment-level promotion PR automation.
- Add progressive delivery strategy for production sync.
- Add manifest security scanning and SBOM verification.
