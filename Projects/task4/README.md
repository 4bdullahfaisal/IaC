# Task 4: Mini Project - Automated Infrastructure as Code & Orchestration

![Terraform](https://img.shields.io/badge/Terraform-1.6.x-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Cluster-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Network-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![HA](https://img.shields.io/badge/Availability-High%20Availability-00C7B7?style=for-the-badge)

## Project Title

TASK 4: Mini Project - Automated Infrastructure as Code & Orchestration

## Exact Task Requirement

The original Task 4 question is:

```text
TASK 4: Mini Project - Automated Infrastructure as Code & Orchestration
Architecture
○ Objective: Provision and orchestrate an elastic, highly available microservices
cluster environment.
○ Requirements: Map cloud network resources programmatically using declarative
Infrastructure as Code tools (Terraform or CloudFormation) to spin up isolated
networks. Deploy your containerized application stack across a Kubernetes
(EKS/GKE/Minikube) cluster setup, configuring persistent volume claims, Ingress
controller endpoints, and Horizontal Pod Autoscalers (HPA)
```

Architecture

- Objective: Provision and orchestrate an elastic, highly available microservices cluster environment.
- Requirements: Map cloud network resources programmatically using declarative Infrastructure as Code tools (Terraform or CloudFormation) to spin up isolated networks.
- Deploy your containerized application stack across a Kubernetes (EKS/GKE/Minikube) cluster setup, configuring persistent volume claims, Ingress controller endpoints, and Horizontal Pod Autoscalers (HPA).

This project follows that exact requirement by combining Terraform and Kubernetes to build a small but realistic infrastructure for an NGINX-based web application with redundancy, scaling, and service exposure.

---

## Why We Are Doing This

This task is designed to teach and demonstrate the core principles of modern DevOps and cloud-native deployment. In real-world environments, infrastructure cannot be manually configured one-by-one. Instead, we define resources as code so they can be repeated, versioned, tested, and deployed consistently.

The main reasons for this project are:

- Infrastructure as Code (IaC) makes deployments repeatable and error-resistant.
- Kubernetes gives us a reliable way to run containerized applications at scale.
- HA (High Availability) is important because services should not go down when a single instance fails.
- Persistent storage allows application data to survive pod restarts or rescheduling.
- Ingress provides a clean entry point for clients to access services.
- HPA enables automatic scaling based on real metrics such as CPU usage.

---

## Project Goal

The purpose of this project is to:

1. Create an isolated network using Terraform.
2. Deploy a containerized web application into Kubernetes.
3. Use a PersistentVolumeClaim to preserve data.
4. Expose the app using a Service and Ingress.
5. Keep the app available through multiple replicas.
6. Enable automatic scaling using a HorizontalPodAutoscaler.

---

## Architecture Overview

This solution is a small cloud-native environment where:

- Terraform provisions the networking foundation.
- Kubernetes runs the application containers.
- A Deployment manages app replicas.
- A Service exposes those pods inside the cluster.
- An Ingress routes external traffic to the app.
- HPA watches metrics and scales pods automatically.

```text
Client / Browser
        |
        v
    Ingress (task4.local)
        |
        v
      Service: web
        |
   +----+------------------+
   |                       |
   v                       v
Pod 1 (nginx)          Pod 2 (nginx)
   |                       |
   +-----------+-----------+
               v
         PVC: web-content
```

---

## Technologies Used

- Terraform
- Docker provider for Terraform
- Kubernetes manifests
- NGINX container image
- PersistentVolumeClaim
- Service and Ingress objects
- HorizontalPodAutoscaler (HPA)

---

## Folder Structure

```text
task4/
├── README.md
├── task4.md
├── .gitignore
├── k8s/
│   ├── namespace.yaml
│   ├── pvc.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── hpa.yaml
│   └── ingress.yaml
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── .terraform.lock.hcl
    └── terraform.tfstate
```

---

## Prerequisites

Install the following tools before starting:

- Docker Desktop with its Docker Engine running
- Terraform 1.6 or newer
- `kubectl`
- Minikube, or access to an existing EKS/GKE/Kubernetes cluster
- An NGINX Ingress controller
- Kubernetes Metrics Server for HPA CPU metrics

Check the local installations:

```bash
docker --version
terraform version
kubectl version --client
minikube version
```

The examples below use Minikube because it is the simplest Kubernetes option for a local demonstration. The Kubernetes YAML is portable to EKS, GKE, and other conformant clusters, but the Ingress address and storage class depend on the selected cluster.

### Start a Local Minikube Cluster

```bash
minikube start --driver=docker
minikube addons enable ingress
minikube addons enable metrics-server
kubectl config use-context minikube
kubectl cluster-info
```

The Ingress addon creates the NGINX Ingress controller required by `ingress.yaml`. The Metrics Server provides the CPU values required by `hpa.yaml`. Without Metrics Server, the application can run, but the HPA will show unknown metrics and cannot make scaling decisions.

On Windows, run the following command in an Administrator PowerShell if `task4.local` does not resolve automatically:

```powershell
Add-Content -Path "$env:WINDIR\System32\drivers\etc\hosts" -Value "127.0.0.1 task4.local"
```

Alternatively, use the Minikube tunnel in a separate terminal:

```bash
minikube tunnel
```

Keep that terminal running while testing the Ingress address.

---

## What Each File Does

The project is intentionally split into small declarative files. Each file describes the desired state of one infrastructure or Kubernetes resource.

| File | Purpose | Why it is required |
| --- | --- | --- |
| `terraform/main.tf` | Declares the Docker provider and isolated bridge network | Creates the network from code instead of manual commands |
| `terraform/variables.tf` | Defines the configurable network name | Allows the same code to be reused with another name |
| `terraform/outputs.tf` | Prints the created network name | Makes the result visible after `terraform apply` |
| `k8s/namespace.yaml` | Creates the `task4` namespace | Keeps this project isolated from other workloads |
| `k8s/pvc.yaml` | Requests 1 GiB of persistent storage | Preserves application data across pod restarts |
| `k8s/deployment.yaml` | Runs the NGINX containers | Defines replicas, image, resources, probes, and storage |
| `k8s/service.yaml` | Gives the pods a stable internal endpoint | Routes traffic to healthy pods without using pod IPs |
| `k8s/hpa.yaml` | Scales the Deployment from 2 to 5 replicas | Provides elasticity when average CPU reaches 60% |
| `k8s/ingress.yaml` | Routes `task4.local` to the Service | Provides an HTTP entry point for users |

### Important Resource Relationships

The names and labels connect the resources:

```text
Ingress web
  host: task4.local
  path: /
        |
        v
Service web :80
  selector: app=web
        |
        v
Deployment web
  pod labels: app=web
  replicas: 2 to 5
        |
        v
NGINX pods
  mount PVC web-content at /usr/share/nginx/html/data
```

The Service selector must match the Deployment pod label. The PVC name in the Deployment must match the PVC metadata name. The HPA target must match the Deployment name. If any of these names change, the connected files must be updated together.

### Local Network Scope

This repository uses Terraform's Docker provider to create `task4-network`, which is an isolated local Docker bridge network. It demonstrates the requested declarative network provisioning on a local machine. The Kubernetes cluster is still configured separately by Minikube.

For a production EKS or GKE implementation, the equivalent Terraform layer would use the cloud provider's VPC/VNet, subnets, route tables, security groups, and managed Kubernetes resources. The Kubernetes files can then be applied to that cluster with the appropriate cloud storage class and Ingress controller.

---

## Step 1: Create the Network with Terraform

The first part of the project is to map the network resource using declarative IaC. We use Terraform to create a Docker bridge network named `task4-network` by default.

This is a good example of infrastructure provisioning because the network is created from code rather than manually through a GUI or shell commands.

### Terraform File: [terraform/main.tf](terraform/main.tf)

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "task4" {
  name   = var.network_name
  driver = "bridge"
}
```

### Terraform File: [terraform/variables.tf](terraform/variables.tf)

```hcl
variable "network_name" {
  description = "Name of the isolated local Docker network."
  type        = string
  default     = "task4-network"
}
```

### Terraform File: [terraform/outputs.tf](terraform/outputs.tf)

```hcl
output "network_name" {
  description = "Created local Docker network name."
  value       = docker_network.task4.name
}
```

### Terraform Commands

```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

When Terraform asks for confirmation, type `yes`. To use a different network name without editing the file:

```bash
terraform apply -var="network_name=task4-network-dev"
terraform output network_name
```

Check that the network exists:

```bash
docker network ls
docker network inspect task4-network
```

### Why This Part Matters

- It defines the environment in code.
- It creates an isolated networking layer.
- It is repeatable and easy to manage.
- It matches the requirement to map cloud/network resources programmatically.

---

## Step 2: Create the Kubernetes Namespace

Before deploying the workload, we create a dedicated namespace so the resources are isolated and organized.

### Kubernetes File: [k8s/namespace.yaml](k8s/namespace.yaml)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: task4
```

### Apply Namespace

```bash
kubectl apply -f k8s/namespace.yaml
```

---

## Step 3: Create Persistent Storage with PVC

Applications often need storage for static files, uploaded content, or runtime data. In Kubernetes, the `PersistentVolumeClaim` is used to request storage from the underlying cluster.

### Kubernetes File: [k8s/pvc.yaml](k8s/pvc.yaml)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-content
  namespace: task4
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### Apply PVC

```bash
kubectl apply -f k8s/pvc.yaml
```

### Why This Is Needed

- keeps application data persistent
- makes the app more resilient
- allows content storage even when pods restart or move

---

## Step 4: Deploy the NGINX Application

The core application is a web server using NGINX, running in a Kubernetes Deployment. We create 2 replicas to ensure availability.

### Kubernetes File: [k8s/deployment.yaml](k8s/deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: task4
  labels:
    app: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - name: http
              containerPort: 80
          resources:
            requests:
              cpu: 100m
              memory: 64Mi
            limits:
              cpu: 500m
              memory: 128Mi
          volumeMounts:
            - name: web-content
              mountPath: /usr/share/nginx/html/data
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 3
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 10
            periodSeconds: 10
      volumes:
        - name: web-content
          persistentVolumeClaim:
            claimName: web-content
```

### Apply Deployment

```bash
kubectl apply -f k8s/deployment.yaml
```

### Why This Is Important

- ensures the app runs continuously
- provides fault tolerance through multiple pods
- uses health probes to detect unhealthy containers
- keeps resource limits in place for stability

---

## Step 5: Expose the Application Using a Service

A Kubernetes Service creates a stable IP address and routes traffic to pods. This is how internal components can talk to the app reliably.

### Kubernetes File: [k8s/service.yaml](k8s/service.yaml)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: task4
spec:
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: http
  type: ClusterIP
```

### Apply Service

```bash
kubectl apply -f k8s/service.yaml
```

### Why We Use a Service

- provides a stable endpoint for the application
- load-balances traffic across pods
- hides individual pod IPs from clients

---

## Step 6: Add Auto Scaling with HPA

The Horizontal Pod Autoscaler monitors CPU usage and automatically scales the number of app replicas.

### Kubernetes File: [k8s/hpa.yaml](k8s/hpa.yaml)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web
  namespace: task4
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 5
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 60
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
```

### Apply HPA

```bash
kubectl apply -f k8s/hpa.yaml
```

### Why HPA Matters

- keeps app performance stable under load
- supports elastic scaling in real-time
- reduces cost by scaling down when demand decreases
- directly matches the requirement for Horizontal Pod Autoscaler configuration

---

## Step 7: Expose the App with Ingress

Ingress gives the application an HTTP endpoint for external access. In this case, the app is routed from `task4.local` to the `web` service.

### Kubernetes File: [k8s/ingress.yaml](k8s/ingress.yaml)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: task4
spec:
  ingressClassName: nginx
  rules:
    - host: task4.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  name: http
```

### Apply Ingress

```bash
kubectl apply -f k8s/ingress.yaml
```

### Host Configuration

If you are testing locally, add this entry to your hosts file:

```bash
127.0.0.1 task4.local
```

Then open:

```text
http://task4.local/
```

---

## Full Deployment Sequence

This is the complete set of commands used to deploy the project:

```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply

cd ..
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/ingress.yaml
```

The Kubernetes resources can also be applied as one directory:

```bash
kubectl apply -f k8s/
```

Applying the files individually is useful for learning because it shows the order and purpose of every resource. Applying the directory is convenient for repeatable redeployments. Kubernetes converges the declared resources to the same desired state either way.

### Watch the Rollout

```bash
kubectl rollout status deployment/web -n task4
kubectl get pods -n task4 -w
```

Stop the watch with `Ctrl+C` after both initial replicas show `Running` and `Ready`.

---

## Verification Commands

After deployment, verify that everything is running correctly:

```bash
kubectl get ns
kubectl get pods -n task4
kubectl get svc -n task4
kubectl get hpa -n task4
kubectl get ingress -n task4
kubectl describe deployment web -n task4
kubectl describe hpa web -n task4
```

Check the metrics used by the HPA:

```bash
kubectl top pods -n task4
kubectl get hpa web -n task4
```

The HPA may briefly show `<unknown>` immediately after deployment while Metrics Server collects its first samples. Wait a short time and run the commands again.

Test the Service without relying on Ingress:

```bash
kubectl port-forward service/web 8080:80 -n task4
```

Open `http://localhost:8080` in a browser while the port-forward command is running. This isolates application and Service testing from DNS and Ingress configuration.

Test the Ingress:

```bash
curl http://task4.local/
kubectl describe ingress web -n task4
```

On Minikube, obtain the Ingress IP if needed:

```bash
minikube ip
kubectl get ingress web -n task4
```

If the Ingress address is not `127.0.0.1`, map `task4.local` to the address shown by `kubectl get ingress` in the hosts file.

Expected result:

- namespace `task4` exists
- deployment has 2 running replicas
- service is created and routing traffic
- HPA is active with min = 2 and max = 5
- ingress points to the service

---

## Result of the Project

When the setup is successful, the system gives us:

- an isolated Docker network created by Terraform
- a Kubernetes deployment for a web stack
- persistent storage using PVC
- reliable internal communication using a Service
- external app access through Ingress
- automatic scaling with HPA
- a highly available microservice-style environment

This fully addresses the assignment objective of provisioning and orchestrating an elastic, highly available cluster environment.

---

## Failure Handling and Troubleshooting

### Pods are Pending

```bash
kubectl describe pod -l app=web -n task4
kubectl get pvc -n task4
kubectl get events -n task4 --sort-by=.lastTimestamp
```

The most common causes are an unavailable storage provisioner, insufficient cluster resources, or a PVC that has not reached `Bound` status.

### HPA Has Unknown Metrics

```bash
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
kubectl top pods -n task4
```

Enable Metrics Server for Minikube with `minikube addons enable metrics-server`. The Deployment also includes CPU requests because HPA utilization is calculated relative to requested CPU.

### Ingress Returns 404 or Has No Address

```bash
kubectl get ingressclass
kubectl get pods -n ingress-nginx
kubectl describe ingress web -n task4
```

The cluster must have an IngressClass named `nginx` and a running NGINX Ingress controller. Also verify that `task4.local` resolves to the cluster's Ingress address.

### Service Has No Endpoints

```bash
kubectl get pods -n task4 --show-labels
kubectl get endpoints web -n task4
```

The Service selects `app: web`, so the Deployment pods must have exactly that label and must pass their readiness probe.

---

## Cleanup

Remove the Kubernetes resources after testing:

```bash
kubectl delete -f k8s/
```

Destroy the Terraform-managed local network:

```bash
cd terraform
terraform destroy
```

Delete the local Minikube cluster only when it is no longer needed:

```bash
minikube delete
```

`terraform destroy` removes only resources managed by the Terraform state. `kubectl delete -f k8s/` removes the Kubernetes objects described by this project.

---

## Requirement Checklist

The exact Task 4 requirement is satisfied as follows:

| Task 4 requirement | Project implementation |
| --- | --- |
| Provision and orchestrate an elastic, highly available microservices cluster environment | Kubernetes Deployment starts two NGINX replicas and HPA can increase them to five |
| Map cloud network resources programmatically | `terraform/main.tf` declares an isolated Docker network as the local IaC equivalent |
| Use declarative Infrastructure as Code | Terraform `.tf` files describe the network's desired state |
| Deploy a containerized application stack on Kubernetes | `deployment.yaml` runs `nginx:1.27-alpine` in Kubernetes |
| Configure persistent volume claims | `pvc.yaml` requests 1 GiB and the Deployment mounts it |
| Configure an Ingress controller endpoint | `ingress.yaml` routes `task4.local/` to the `web` Service using the NGINX class |
| Configure a Horizontal Pod Autoscaler | `hpa.yaml` targets CPU utilization at 60%, with 2–5 replicas |

This is a local, reproducible implementation of the assignment. Moving it to EKS or GKE requires replacing the local Terraform network/provider with cloud networking resources and selecting the cluster's supported storage and Ingress implementations.

---

## What This Project Teaches

This project demonstrates practical DevOps and cloud engineering skills:

- Infrastructure as Code with Terraform
- Declarative resource management
- Container orchestration with Kubernetes
- Persistent data handling
- Service discovery and routing
- Resilience and HA design
- Horizontal autoscaling strategy
- Real-world deployment automation mindset

---

## Final Summary

In simple terms, this project creates a basic but realistic cloud-native architecture where an app is deployed in Kubernetes, backed by persistent storage, exposed through a service and ingress, and automatically scaled based on CPU usage. It uses Infrastructure as Code to minimize manual work and ensures the environment is repeatable, scalable, and maintainable.

The assignment requirement is fully represented in this project and follows the exact task outline:

- map cloud network resources programmatically
- use declarative IaC tools
- deploy containerized apps in Kubernetes
- configure PVC, Ingress, and HPA

---
