# Day 16 – Kubernetes Deployment + Ingress Routing

**Date:** 7 April 2026 (Tuesday)  
**Name:** Solutionara  
**Topic:** K8s Deploy + Ingress Routing  
**Environment:** Minikube | Ubuntu (WSL) | Windows 11  
**Location:** Gurugram, Haryana, IN  

---

## 1. Objective

- Deploy an application using Kubernetes Deployment + Service.
- Configure NGINX Ingress for host-based routing via `devops.local`.
- Map `devops.local` hostname to local Minikube cluster IP.
- Verify app is accessible via browser and `curl`.

---

## 2. What is Kubernetes Ingress?

Ingress is a Kubernetes API object that manages **external HTTP/HTTPS access** to Services inside the cluster.

### Without Ingress:
- You need NodePort or LoadBalancer for every Service.
- URLs are messy: `http://192.168.49.2:30080`

### With Ingress:
- One single entry point (port 80/443).
- Clean URLs: `http://devops.local`
- Host-based routing: `app1.devops.local`, `app2.devops.local`
- Path-based routing: `/app1`, `/app2`
- TLS/HTTPS termination support.

### Two parts of Ingress:
| Part | Description |
|------|-------------|
| Ingress Resource | YAML rules that define routing |
| Ingress Controller | Actual reverse proxy (NGINX) that reads rules and routes traffic |

---

## 3. Concepts Covered

### Deployment
- Manages pods and ensures desired replicas are running.
- Uses `selector.matchLabels` to identify which pods it manages.

### Service (ClusterIP)
- Gives a stable internal IP/DNS to access pods.
- `ClusterIP` = internal only (used with Ingress).
- `NodePort` = external access via node IP + port.
- Labels in Service `selector` must match pod labels in Deployment.

### Ingress
- Routes HTTP traffic based on hostname or path.
- Requires NGINX Ingress Controller to be running.
- Points to a Service (not directly to pods).

### kubectl port-forward
- Temporary tunnel from your local machine to a cluster Service/Pod.
- Only for testing and debugging.
- Does NOT work in production.

---

---

## 4. YAML Files

### deployment.yml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
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
            - containerPort: 80
```

**Explanation:**
| Field | Meaning |
|-------|---------|
| `replicas: 1` | Run 1 pod |
| `selector.matchLabels` | Manage pods with label `app: myapp` |
| `image: myapp:local` | Use local Docker image |
| `imagePullPolicy: Never` | Don't pull from registry, use local image |
| `containerPort: 80` | App listens on port 80 inside container |

---

### service.yml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: devops-app-svc
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 80
```

**Explanation:**
| Field | Meaning |
|-------|---------|
| `type: ClusterIP` | Internal only, accessible within cluster |
| `selector: app: myapp` | Route traffic to pods with this label |
| `port: 80` | Service listens on port 80 |
| `targetPort: 80` | Forward to container port 80 |

---

### ingress.yml

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: devops-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: devops.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: devops-app-svc
                port:
                  number: 80
```

**Explanation:**
| Field | Meaning |
|-------|---------|
| `ingressClassName: nginx` | Use NGINX Ingress Controller |
| `host: devops.local` | Match requests for this hostname |
| `path: /` | Match all paths |
| `pathType: Prefix` | Match anything starting with `/` |
| `backend.service.name` | Forward to `devops-app-svc` |
| `backend.service.port` | On port 80 |

---

## 5. Step-by-Step Commands

### Step 1 – Start Minikube
```bash
minikube start
kubectl get nodes
```

### Step 2 – Enable NGINX Ingress Controller
```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx
```

### Step 3 – Build local Docker image inside Minikube
```bash
eval $(minikube docker-env)
docker build -t myapp:local .
```

### Step 4 – Apply all YAML files
```bash
kubectl apply -f k8s/
```

### Step 5 – Verify resources
```bash
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get endpoints devops-app-svc
```

### Step 6 – Test with port-forward
```bash
# Terminal 1
kubectl port-forward service/devops-app-svc 7070:80

# Terminal 2
curl -v http://127.0.0.1:7070
```

### Step 7 – Test via Ingress hostname
```bash
curl http://devops.local
```

### Step 8 – Debug if needed
```bash
# Check pod logs
kubectl logs <pod-name>

# Check pod labels
kubectl get pods --show-labels

# Check endpoints
kubectl get endpoints devops-app-svc

# Exec into pod
kubectl exec -it <pod-name> -- sh
ss -tulnp

# Check Ingress controller logs
kubectl logs -n ingress-nginx \
  $(kubectl get pods -n ingress-nginx -o name | head -n1)
```

---

## 9. Issues Faced & Fixes

| # | Issue | Cause | Fix |
|---|-------|-------|-----|
| 1 | `No resources found in ingress-nginx` | Ingress addon not enabled | `minikube addons enable ingress` |
| 2 | `port-forward timed out` | Service selector `app: devops-app` didn't match pod label `app: myapp` | Changed selector to `app: myapp` in `service.yml` |
| 3 | `Connection refused on port 80` | App not listening on port 80 inside container | Verify using `kubectl exec` + `ss -tulnp`, fix `targetPort` |
| 4 | `sudo kubectl` authentication error | Root user has no kubeconfig | Always use `kubectl` without `sudo` |
| 5 | `deployment unchanged` | No actual changes in YAML | Edit YAML first, then re-apply |
| 6 | `kubectl get images` not found | No such kubectl command | Use `kubectl get pods -o jsonpath="{..image}"` |

---

## 10. Useful kubectl Commands Reference

```bash
# Get all resources
kubectl get all

# Get namespaces
kubectl get ns

# Get pods with labels
kubectl get pods --show-labels

# Get images used in deployments
kubectl get deploy myapp -o=jsonpath="{..image}"

# Delete deployment
kubectl delete deploy myapp

# Delete service
kubectl delete svc devops-app-svc

# Delete using file
kubectl delete -f k8s/

# Describe ingress
kubectl describe ingress devops-app-ingress

# Watch pods in real time
kubectl get pods -w
```

---

## 11. Key Takeaways

- Labels and selectors **must match exactly** between Deployment and Service.
- `ClusterIP` + Ingress is the **production-like pattern**, not NodePort.
- `kubectl port-forward` is **only for local debugging**, not production use.
- Ingress Controller **must be running** before Ingress resources work.
- Always use `kubectl` **without sudo** to avoid kubeconfig issues.
- `imagePullPolicy: Never` is used when image is built locally inside Minikube.
- `containerPort`, `targetPort`, and actual app port **must all match**.

---


