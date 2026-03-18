# mypythonproject1-gitops

GitOps repository for **mypythonproject1** — manages Kubernetes/EKS deployments via ArgoCD.

## Repository Layout

```
mypythonproject1-gitops/
├── apps/                          # ArgoCD App-of-Apps manifests
│   ├── app-of-apps.yaml           # Root ArgoCD Application (bootstrapped once)
│   ├── staging/
│   │   └── mypythonproject1.yaml  # ArgoCD Application for staging
│   └── production/
│       └── mypythonproject1.yaml  # ArgoCD Application for production
│
├── charts/
│   └── mypythonproject1/          # Helm chart for the application
│       ├── Chart.yaml
│       ├── values.yaml            # Chart defaults (do not use directly)
│       └── templates/
│           ├── _helpers.tpl
│           ├── backend/
│           │   ├── deployment.yaml
│           │   ├── service.yaml
│           │   ├── hpa.yaml
│           │   └── pdb.yaml
│           ├── frontend/
│           │   ├── deployment.yaml
│           │   ├── service.yaml
│           │   ├── hpa.yaml
│           │   └── pdb.yaml
│           ├── ingress.yaml
│           └── serviceaccount.yaml
│
└── environments/
    ├── staging/
    │   └── values.yaml            # Staging overrides (image tags updated by CI)
    └── production/
        └── values.yaml            # Production overrides (image tags updated by CI)
```

## Deployment Flow

```
App repo CI
    │
    ├─ develop branch → CI success
    │       │
    │       └─ cd-eks-gitops.yml builds image (staging-<sha>)
    │               └─ updates environments/staging/values.yaml
    │                       └─ ArgoCD auto-syncs → EKS staging namespace
    │
    └─ tag v* (from semantic-release on main)
            │
            └─ cd-eks-gitops.yml builds image (v1.2.3)
                    └─ updates environments/production/values.yaml
                            └─ ArgoCD auto-syncs → EKS production namespace
```

## Bootstrap ArgoCD

```bash
# One-time: register the root App-of-Apps with your ArgoCD instance
argocd app create app-of-apps \
  --repo https://github.com/YilingCAI/mypythonproject1-gitops.git \
  --path apps \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

## Secrets

All application secrets (DB password, JWT key, etc.) are managed via **AWS Secrets Manager** and injected into pods using the [AWS Secrets Store CSI driver](https://github.com/aws/secrets-store-csi-driver-provider-aws). No secrets are stored in this repository.
