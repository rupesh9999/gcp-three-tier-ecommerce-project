# Jenkins Configuration Guide for E-Commerce Application

## 1. Access Jenkins

Wait for Jenkins to be ready (may take 2-3 minutes):

```bash
kubectl get pods -n jenkins -w
```

Get Jenkins initial admin password:

```bash
kubectl exec -n jenkins $(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword
```

Get Jenkins external IP:

```bash
kubectl get svc -n jenkins
```

Access Jenkins at: `http://<EXTERNAL_IP>/jenkins`

## 2. Initial Setup

1. **Unlock Jenkins** - Use the password from above
2. **Install Suggested Plugins** - Click "Install suggested plugins"
3. **Create Admin User**:
   - Username: `admin`
   - Password: `<your-secure-password>`
   - Full name: `Jenkins Admin`
   - Email: `admin@example.com`

## 3. Install Required Plugins

Navigate to: **Manage Jenkins → Manage Plugins → Available**

Install the following plugins:
- ✅ Docker Pipeline
- ✅ Kubernetes
- ✅ Google Kubernetes Engine
- ✅ Google Container Registry Auth
- ✅ Git
- ✅ Pipeline
- ✅ Maven Integration
- ✅ NodeJS
- ✅ Slack Notification (optional)
- ✅ JUnit
- ✅ Blue Ocean (optional, for better UI)

Click **Install without restart** and check **Restart Jenkins when no jobs are running**.

## 4. Configure Global Tools

### 4.1 Configure JDK

Navigate to: **Manage Jenkins → Global Tool Configuration → JDK**

- Click **Add JDK**
- Name: `JDK-17`
- Install automatically: ✅ Checked
- Select: **Install from adoptium.net**
- Version: **jdk-17.0.9+9**

### 4.2 Configure Maven

Navigate to: **Manage Jenkins → Global Tool Configuration → Maven**

- Click **Add Maven**
- Name: `Maven-3.9`
- Install automatically: ✅ Checked
- Version: **3.9.5**

### 4.3 Configure NodeJS

Navigate to: **Manage Jenkins → Global Tool Configuration → NodeJS**

- Click **Add NodeJS**
- Name: `NodeJS-18`
- Install automatically: ✅ Checked
- Version: **NodeJS 18.18.0**
- Global npm packages: `typescript @types/node`

### 4.4 Configure Docker

Navigate to: **Manage Jenkins → Global Tool Configuration → Docker**

- Click **Add Docker**
- Name: `Docker`
- Install automatically: ✅ Checked
- Docker version: **latest**

Click **Save**

## 5. Configure Credentials

Navigate to: **Manage Jenkins → Manage Credentials → (global) → Add Credentials**

### 5.1 GitHub Credentials

- Kind: **Username with password**
- Scope: **Global**
- Username: `<your-github-username>`
- Password: `<your-github-personal-access-token>`
- ID: `github-credentials`
- Description: `GitHub Access Token`

### 5.2 GCP Service Account Key

First, create a service account key:

```bash
# Create service account
gcloud iam service-accounts create jenkins-gke \\
  --display-name="Jenkins GKE Service Account"

# Grant necessary permissions
gcloud projects add-iam-policy-binding vaulted-harbor-476903-t8 \\
  --member="serviceAccount:jenkins-gke@vaulted-harbor-476903-t8.iam.gserviceaccount.com" \\
  --role="roles/container.developer"

gcloud projects add-iam-policy-binding vaulted-harbor-476903-t8 \\
  --member="serviceAccount:jenkins-gke@vaulted-harbor-476903-t8.iam.gserviceaccount.com" \\
  --role="roles/artifactregistry.writer"

# Create key
gcloud iam service-accounts keys create jenkins-key.json \\
  --iam-account=jenkins-gke@vaulted-harbor-476903-t8.iam.gserviceaccount.com
```

In Jenkins:
- Kind: **Secret file**
- File: Upload `jenkins-key.json`
- ID: `gcp-service-account`
- Description: `GCP Service Account for GKE & Artifact Registry`

### 5.3 Docker Registry Credentials

- Kind: **Username with password**
- Username: `_json_key`
- Password: `<paste content of jenkins-key.json>`
- ID: `gcr-credentials`
- Description: `GCP Artifact Registry`

### 5.4 Kubeconfig

```bash
# Get kubeconfig
kubectl config view --raw > kubeconfig.yaml
```

In Jenkins:
- Kind: **Secret file**
- File: Upload `kubeconfig.yaml`
- ID: `kubeconfig`
- Description: `Kubernetes Config for GKE`

## 6. Configure Cloud (Kubernetes)

Navigate to: **Manage Jenkins → Manage Nodes and Clouds → Configure Clouds → Add a new cloud → Kubernetes**

- Name: `kubernetes`
- Kubernetes URL: `https://kubernetes.default`
- Kubernetes Namespace: `jenkins`
- Credentials: Select **kubeconfig** (from above)
- Jenkins URL: `http://jenkins.jenkins.svc.cluster.local:8080/jenkins`
- Jenkins tunnel: `jenkins.jenkins.svc.cluster.local:50000`

Click **Test Connection** - Should show "Connected to Kubernetes"

### 6.1 Pod Templates

Click **Add Pod Template**:

**Maven Build Pod:**
- Name: `maven-build`
- Namespace: `jenkins`
- Labels: `maven`

Add Container:
- Name: `maven`
- Docker image: `maven:3.9-eclipse-temurin-17`
- Command: `/bin/sh -c`
- Arguments: `cat`
- TTY: ✅ Checked

Add Container:
- Name: `docker`
- Docker image: `docker:dind`
- Privileged: ✅ Checked

**Node.js Build Pod:**
- Name: `nodejs-build`
- Namespace: `jenkins`
- Labels: `nodejs`

Add Container:
- Name: `nodejs`
- Docker image: `node:18-alpine`
- Command: `/bin/sh -c`
- Arguments: `cat`
- TTY: ✅ Checked

Click **Save**

## 7. Configure Global Environment Variables

Navigate to: **Manage Jenkins → Configure System → Global properties → Environment variables**

Add the following:
- Name: `GCP_PROJECT_ID`, Value: `vaulted-harbor-476903-t8`
- Name: `GKE_CLUSTER`, Value: `ecommerce-cluster`
- Name: `GKE_ZONE`, Value: `us-central1-a`
- Name: `DOCKER_REGISTRY`, Value: `us-central1-docker.pkg.dev`
- Name: `REPO_NAME`, Value: `ecommerce-repo`

## 8. Create Pipeline Jobs

### 8.1 User Service Pipeline

1. Click **New Item**
2. Enter name: `user-service-pipeline`
3. Select: **Pipeline**
4. Click **OK**

Configuration:
- Description: `CI/CD Pipeline for User Service`
- **Build Triggers**: 
  - ✅ GitHub hook trigger for GITScm polling
- **Pipeline**:
  - Definition: **Pipeline script from SCM**
  - SCM: **Git**
  - Repository URL: `https://github.com/rupesh9999/gcp-three-tier-ecommerce-project.git`
  - Credentials: Select **github-credentials**
  - Branch: `*/main`
  - Script Path: `backend/user-service/Jenkinsfile`

Click **Save**

### 8.2 Product Service Pipeline

Repeat above steps with:
- Name: `product-service-pipeline`
- Script Path: `backend/product-service/Jenkinsfile`

### 8.3 Order Service Pipeline

Repeat above steps with:
- Name: `order-service-pipeline`
- Script Path: `backend/order-service/Jenkinsfile`

### 8.4 Frontend Pipeline

Repeat above steps with:
- Name: `frontend-pipeline`
- Script Path: `frontend/Jenkinsfile`

## 9. Configure GCP Authentication in Jenkins Pod

```bash
# Copy service account key to Jenkins pod
kubectl cp jenkins-key.json jenkins/$(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}'):/var/jenkins_home/jenkins-key.json

# Exec into Jenkins pod
kubectl exec -it -n jenkins $(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}') -- /bin/bash

# Authenticate with GCP
gcloud auth activate-service-account --key-file=/var/jenkins_home/jenkins-key.json
gcloud config set project vaulted-harbor-476903-t8

# Configure Docker to use gcloud as credential helper
gcloud auth configure-docker us-central1-docker.pkg.dev

# Get GKE credentials
gcloud container clusters get-credentials ecommerce-cluster --zone=us-central1-a

exit
```

## 10. Test Pipeline

1. Go to **user-service-pipeline**
2. Click **Build Now**
3. Monitor the build in **Console Output**

Expected stages:
- ✅ Checkout
- ✅ Build
- ✅ Unit Tests
- ✅ Build Docker Image
- ✅ Push to Artifact Registry
- ✅ Deploy to GKE
- ✅ Health Check

## 11. Configure Webhooks (Optional)

### GitHub Webhook

1. Go to GitHub repository: **Settings → Webhooks → Add webhook**
2. Payload URL: `http://<JENKINS_EXTERNAL_IP>/jenkins/github-webhook/`
3. Content type: `application/json`
4. Events: **Just the push event**
5. Active: ✅ Checked
6. Click **Add webhook**

Now pushing to main branch will automatically trigger builds!

## 12. Backup Configuration

```bash
# Backup Jenkins home directory
kubectl exec -n jenkins $(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}') -- tar czf /tmp/jenkins-backup.tar.gz /var/jenkins_home

# Copy backup to local
kubectl cp jenkins/$(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}'):/tmp/jenkins-backup.tar.gz ./jenkins-backup.tar.gz
```

## Troubleshooting

### Jenkins Pod Not Starting
```bash
kubectl logs -n jenkins $(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod -n jenkins $(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}')
```

### Docker Build Fails
- Ensure Docker daemon is running in Jenkins pod
- Check if Docker-in-Docker (dind) sidecar is configured

### GKE Deployment Fails
- Verify service account has correct permissions
- Check kubeconfig is valid
- Ensure cluster is reachable from Jenkins

### Image Push Fails
- Verify Artifact Registry permissions
- Check Docker authentication: `gcloud auth configure-docker`

## Security Best Practices

1. ✅ Use strong admin password
2. ✅ Enable CSRF protection
3. ✅ Use credentials for all secrets
4. ✅ Restrict script approval
5. ✅ Enable audit logging
6. ✅ Regular backups
7. ✅ Keep Jenkins and plugins updated

---

**Jenkins URL**: http://<EXTERNAL_IP>/jenkins
**Username**: admin
**Initial Password**: (from kubectl command above)
