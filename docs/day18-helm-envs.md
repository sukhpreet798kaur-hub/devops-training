# Day 18 – Helm chart + env values

## Goal

Create a reusable Helm chart for `myapp` with environment-specific configuration:
- `values-dev.yaml` for local/dev.
- `values-prod.yaml` for stricter prod (more replicas, mandatory probes).
- Include helpful post-install notes.

## Chart structure

```text
helm/myapp/
  Chart.yaml
  values.yaml
  values-dev.yaml
  values-prod.yaml
  templates/
    deployment.yaml
    service.yaml
    ingress.yaml
    NOTES.txt
```

`values.yaml` holds common defaults (image, ports, base probe config).  
`values-dev.yaml` and `values-prod.yaml` override replicas, probes, and env name.

## Key configuration

- Dev: `replicaCount: 1`, probes disabled.
- Prod: `replicaCount: 3`, liveness/readiness probes enabled, resources set.

Deployment template reads:
- `.Values.replicaCount` for replicas.
- `.Values.env.name` as `env` label.
- `.Values.livenessProbe` / `.Values.readinessProbe` to conditionally render probes.

## Commands used

```bash
# Create chart
mkdir -p helm
cd helm
helm create helm

# Install dev
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install myapp-dev . -n dev -f values-dev.yaml

# Install prod
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install myapp-prod . -n prod -f values-prod.yaml

# Check releases
helm list -A
solutionara@DESKTOP-VLUHK1Q:~/devops/k8s/helm$ helm list -A
NAME            NAMESPACE       REVISION        UPDATED                                  STATUS          CHART           APP VERSION
myapp-dev       dev             7               2026-04-09 04:33:47.6375249 -0700 PDT    deployed        helm-0.1.0      1.16.0
myapp-pro       prod            2               2026-04-09 04:47:21.12285757 -0700 PDT   deployed        helm-0.1.0      1.16.0
myapp-prod      prod            3               2026-04-09 04:38:41.76640804 -0700 PDT   deployed        helm-0.1.0      1.16.0
```

`NOTES.txt` provides basic access and troubleshooting instructions after install.
