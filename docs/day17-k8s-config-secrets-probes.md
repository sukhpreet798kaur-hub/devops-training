---

## 1. ConfigMap for configuration

### 1.1 ConfigMap YAML (committed to Git)

File: `k8s/myapp-configMap.yml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  APP_ENV: "production"
  LOG_LEVEL: "info"
  APP_PORT: "80"
```

Apply:

```bash
kubectl apply -f k8s/myapp-configmap.yml
```

Check:

```bash
kubectl get configmap myapp-config
```

Notes:

- This file **is committed** to Git because it does not contain secrets.
- Key–values under `data` become environment variables when used with `envFrom`.

---

## 2. Secret for credentials (not in Git)

### 2.1 Create Secret from CLI (no YAML committed)

I created the Secret directly from the terminal so that real passwords are never stored in the repo:

```bash
kubectl create secret generic myapp-secret \
  --from-literal=DB_PASSWORD='TrainApp@2026#DB' \
  --from-literal=DB_NAME='trainingdb' \
  --from-literal=DB_USER='trainingapp'
```

Verification:

```bash
kubectl get secrets
kubectl describe secret myapp-secret
```

Notes:

- **No Secret YAML file** is committed.
- Actual values exist only in the cluster; the repo only contains references to `myapp-secret`.

---

## 3. Deployment with env, ConfigMap, Secret, and probes

### 3.1 Deployment YAML

File: `k8s/myapp-deploy.yml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: myapp:local
          imagePullPolicy: Never
          ports:
            - containerPort: 8080

          # Inject ConfigMap and Secret as env variables
          envFrom:
            - configMapRef:
                name: myapp-config
            - secretRef:
                name: myapp-secret

          # Liveness probe (is container still alive?)
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 3

          # Readiness probe (ready to receive traffic?)
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 5
            failureThreshold: 3
```

Apply:

```bash
kubectl apply -f k8s/myapp-deploy.yml
```

---

## 4. Validate rolling update

### 4.1 Trigger a rollout

```bash
kubectl apply -f k8s/myapp-deploy.yml
kubectl rollout status deploy/myapp
```

### 4.2 Check ReplicaSets and Pods

```bash
kubectl get rs
kubectl get pods -w
```

Expected:

- Old ReplicaSet scaled down to 0 pods.
- New ReplicaSet scaled up to `replicas: 2`.
- Pods for new RS in `Running` and `Ready` status.

---

## 5. Verify env vars and probes on Pod

Pick one of the new pods:

```bash
kubectl get pods
# example: myapp-6b7b54f9d8-9sqww
kubectl describe pod myapp-6b7b54f9d8-9sqww
```

Check in the `describe` output:

- Under `Environment Variables from:` you should see:
  - `myapp-config  ConfigMap`
  - `myapp-secret  Secret`
- Under `Liveness` and `Readiness` you should see the configured probes.

Optional: exec into pod to check env vars:

```bash
kubectl exec -it myapp-6b7b54f9d8-9sqww -- env | grep -E 'APP_|DB_'
```

You should see values from both ConfigMap and Secret, for example:

- `APP_ENV=dev`
- `APP_LOG_LEVEL=debug`
- `DB_NAME=trainingdb`
- `DB_USER=trainingapp`

---

## 6. Summary

- **ConfigMap YAML** is stored in the repo and applied to the cluster.
- **Secret** is created only via CLI; no raw secrets in Git.
- **Deployment** uses `envFrom` for ConfigMap + Secret and includes **liveness** and **readiness** probes.
- **Rolling update** was verified with `kubectl rollout status`, `kubectl get rs`, and `kubectl get pods`, and the final pod description shows correct env vars and probes.
