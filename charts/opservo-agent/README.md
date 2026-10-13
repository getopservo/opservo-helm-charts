# opservo-agent Helm chart

Installs the [Opservo](https://getopservo.com) Kubernetes agent: **one
read-only collector per cluster** that reports nodes, workloads, pods, events
and resource usage, and gets back plain-English findings (crash loops with the
exit code and last log lines, pending pods, node pressure, failed jobs, HPA at
max, missing limits).

This chart is equivalent to the manifest the dashboard hands out
(`kubectl apply -f "<API>/install-k8s.yaml?token=…"`).

## Install

```bash
helm repo add opservo https://getopservo.github.io/opservo-helm-charts
helm install opservo-agent opservo/opservo-agent \
  --namespace opservo --create-namespace \
  --set enrollment.token=ipk_… \
  --set enrollment.clusterName=prod-eks
```

Or from OCI: `helm install opservo-agent oci://ghcr.io/getopservo/charts/opservo-agent -n opservo --create-namespace --set enrollment.token=…`

Get the token in the dashboard: **Add server → Kubernetes cluster**. A
single-use `ipk_…` token is enough — after the first registration the agent
keeps its credentials in the `opservo-agent-credentials` Secret, so restarts
and upgrades do not re-register. For GitOps, keep the token out of values and
point `enrollment.existingSecret` at a Secret you manage (key `OPSERVO_TOKEN`).

Recommended: label the namespace for the restricted Pod Security profile (the
pod already satisfies it):

```bash
kubectl label ns opservo pod-security.kubernetes.io/enforce=restricted
```

## What it can and cannot do

- **Can:** get/list/watch cluster objects, read pod logs, read
  `metrics.k8s.io`, read the API server's `/metrics`.
- **Cannot:** create, change or delete anything — except get/update on its
  own credentials Secret in its own namespace.
- Non-root (UID 65532), read-only root filesystem, all capabilities dropped,
  no hostPath, not privileged, `replicas: 1` (a second copy would double-report).

## Values

| Key | Default | Description |
|---|---|---|
| `enrollment.apiUrl` | `https://api.getopservo.com` | API the agent reports to. |
| `enrollment.token` | `""` | `ipk_…` or `fleet_…` token. Required unless `existingSecret`. |
| `enrollment.clusterName` | `""` | Name in the dashboard (default: API server host). |
| `enrollment.existingSecret` | `""` | Use your own Secret (`OPSERVO_TOKEN`, optional `OPSERVO_API_URL`, `OPSERVO_CLUSTER_NAME`). |
| `image.repository` | `ghcr.io/getopservo/opservo-k8s-agent` | Agent image. |
| `image.tag` | chart `appVersion` | Image tag. |
| `interval` | `60s` | Heartbeat interval. |
| `serviceAccount.name` | `opservo-k8s-agent` | ServiceAccount bound to the read-only ClusterRole. |
| `resources` | 50m/96Mi → 500m/512Mi | Requests / limits. |
| `tolerations` | control-plane NoSchedule | Scheduling. |

## Uninstall

```bash
helm uninstall opservo-agent -n opservo
kubectl -n opservo delete secret opservo-agent-credentials
```

Then remove the cluster in the dashboard.
