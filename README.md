# Opservo Helm charts

Helm chart for the [Opservo](https://getopservo.com) Kubernetes agent: a
read-only collector that explains your cluster in plain English.

```bash
helm repo add opservo https://getopservo.github.io/opservo-helm-charts
helm install opservo-agent opservo/opservo-agent -n opservo --create-namespace \
  --set enrollment.token=<token from Add server → Kubernetes cluster>
```

Chart source and options: [`charts/opservo-agent`](charts/opservo-agent).
Agent source: [getopservo/opservo-agent](https://github.com/getopservo/opservo-agent).
