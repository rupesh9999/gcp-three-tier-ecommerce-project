# Jenkins CI/CD Completion Guide

## Current Status

✅ **Completed:**
- Jenkins deployed on GKE (http://34.46.37.36/jenkins)
- Jenkins credentials: admin / admin@123
- GCP service account `jenkins-gke` created with required permissions:
  - roles/container.developer (for GKE deployments)
  - roles/artifactregistry.writer (for pushing Docker images)
- Service account key file: `jenkins-key.json` (2.4KB)
- Key copied to Jenkins pod at `/var/jenkins_home/jenkins-key.json`
- All 4 Jenkinsfiles created (user-service, product-service, order-service, frontend)

⏳ **Remaining Tasks:**
1. Add credentials in Jenkins UI
2. Create 4 pipeline jobs
3. Test pipeline execution

## Option 1: Using Kubernetes Plugin (Recommended)

This approach runs pipeline stages in separate Kubernetes pods with pre-built images that have all necessary tools.

### Step 1: Install Jenkins Kubernetes Plugin

1. Navigate to: **Manage Jenkins** → **Manage Plugins** → **Available**
2. Search for and install:
   - **Kubernetes plugin**
   - **Docker Pipeline**
   - **Google Kubernetes Engine plugin**
3. Restart Jenkins

### Step 2: Configure Kubernetes Cloud

1. Navigate to: **Manage Jenkins** → **Configure System** → **Cloud** → **Add a new cloud** → **Kubernetes**

2. Configure:
   ```
   Name: kubernetes
   Kubernetes URL: https://kubernetes.default
   Kubernetes Namespace: jenkins
   Credentials: None (uses service account)
   Jenkins URL: http://jenkins:8080/jenkins
   Jenkins tunnel: jenkins:50000
   ```

3. **Add Pod Template:**
   - **Name:** `gcp-builder`
   - **Namespace:** `jenkins`
   - **Labels:** `gcp-builder`
   
4. **Container Template:**
   ```
   Name: gcp-sdk
   Docker image: google/cloud-sdk:latest
   Working directory: /home/jenkins/agent
   Command to run: /bin/sh -c
   Arguments to pass: cat
   Allocate pseudo-TTY: checked
   ```

5. **Volume Mounts:**
   - Mount Path: `/var/jenkins_home`
   - Host Path: (use the jenkins PVC)

### Step 3: Update Jenkinsfiles to Use Kubernetes Pods

For each Jenkinsfile, wrap the stages in a Kubernetes pod declaration:

```groovy
pipeline {
    agent {
        kubernetes {
            label 'gcp-builder'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  serviceAccountName: jenkins
  containers:
  - name: gcp-sdk
    image: google/cloud-sdk:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: jenkins-key
      mountPath: /var/secrets/google
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: maven
    image: maven:3.9-eclipse-temurin-17
    command:
    - cat
    tty: true
  volumes:
  - name: jenkins-key
    secret:
      secretName: jenkins-gcp-key
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    // ... rest of the pipeline
}
```

### Step 4: Create Kubernetes Secret for GCP Key

```bash
kubectl create secret generic jenkins-gcp-key \
  --from-file=key.json=/home/ubuntu/gcp-three-tier-ecommerce-project/jenkins-key.json \
  -n jenkins
```

## Option 2: Using Scripted Credentials (Simpler)

This approach uses the Jenkins credential store and doesn't require custom pods.

### Step 1: Add Credentials in Jenkins

1. **Navigate to:** Manage Jenkins → Manage Credentials → (global) → Add Credentials

2. **Add GCP Service Account:**
   - Kind: `Secret file`
   - File: Upload `/home/ubuntu/gcp-three-tier-ecommerce-project/jenkins-key.json`
   - ID: `gcp-service-account`
   - Description: `GCP Service Account for jenkins-gke`

3. **Add GitHub Credentials:**
   - Kind: `Username with password`
   - Username: `<your-github-username>`
   - Password: `<your-github-personal-access-token>`
   - ID: `github-credentials`
   - Description: `GitHub PAT for repository access`

   **Generate GitHub PAT:**
   - Go to: https://github.com/settings/tokens
   - Click: **Generate new token (classic)**
   - Scopes: `repo` (full control), `admin:repo_hook` (webhooks)
   - Copy the token immediately

4. **Add Docker Registry Credentials:**
   - Kind: `Username with password`
   - Username: `_json_key`
   - Password: Paste the content of `jenkins-key.json` file
   - ID: `gcr-credentials`
   - Description: `GCP Artifact Registry credentials`

### Step 2: Create Pipeline Jobs

For each service, create a pipeline job:

#### Job 1: user-service-pipeline

1. **New Item** → Enter name: `user-service-pipeline` → **Pipeline** → OK
2. **General:**
   - Description: `CI/CD pipeline for User Service`
   - ✓ GitHub project: `https://github.com/rupesh9999/gcp-three-tier-ecommerce-project`
3. **Build Triggers:**
   - ✓ GitHub hook trigger for GITScm polling
4. **Pipeline:**
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/rupesh9999/gcp-three-tier-ecommerce-project.git`
   - Credentials: Select `github-credentials`
   - Branch: `*/main`
   - Script Path: `backend/user-service/Jenkinsfile`
5. **Save**

#### Job 2: product-service-pipeline

- Same as above, but Script Path: `backend/product-service/Jenkinsfile`

#### Job 3: order-service-pipeline

- Same as above, but Script Path: `backend/order-service/Jenkinsfile`

#### Job 4: frontend-pipeline

- Same as above, but Script Path: `frontend/Jenkinsfile`

### Step 3: Modify Jenkinsfiles for Credential-Based Approach

Since the Jenkins pod doesn't have gcloud/kubectl/docker installed, we need to use a different approach:

#### Option 2A: Install Tools via Pipeline Script

Add this stage at the beginning of each Jenkinsfile:

```groovy
stage('Setup Tools') {
    steps {
        script {
            sh '''
                # Install kubectl
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                chmod +x kubectl
                mv kubectl /usr/local/bin/
                
                # Install gcloud SDK
                curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=/tmp/google-cloud-sdk
                export PATH=$PATH:/tmp/google-cloud-sdk/google-cloud-sdk/bin
                
                # Configure gcloud
                gcloud auth activate-service-account --key-file=${GCP_KEY_FILE}
                gcloud config set project ${PROJECT_ID}
                gcloud container clusters get-credentials ${CLUSTER_NAME} --zone=${CLUSTER_ZONE}
            '''
        }
    }
}
```

#### Option 2B: Use Cloud Build (Recommended for Production)

Instead of building in Jenkins, trigger Google Cloud Build:

```groovy
stage('Build and Deploy') {
    steps {
        withCredentials([file(credentialsId: 'gcp-service-account', variable: 'GCP_KEY_FILE')]) {
            sh '''
                gcloud auth activate-service-account --key-file=${GCP_KEY_FILE}
                gcloud config set project vaulted-harbor-476903-t8
                
                # Submit build to Cloud Build
                gcloud builds submit \
                  --config cloudbuild.yaml \
                  --substitutions=_IMAGE_NAME=user-service,_IMAGE_TAG=${BUILD_NUMBER}
            '''
        }
    }
}
```

## Option 3: Use Google Cloud Build (Full Automation)

This is the most elegant solution for GKE deployments.

### Step 1: Create Cloud Build Configuration

Create `backend/user-service/cloudbuild.yaml`:

```yaml
steps:
  # Build Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args: 
      - 'build'
      - '-t'
      - 'us-central1-docker.pkg.dev/vaulted-harbor-476903-t8/ecommerce-repo/user-service:$BUILD_ID'
      - '-t'
      - 'us-central1-docker.pkg.dev/vaulted-harbor-476903-t8/ecommerce-repo/user-service:latest'
      - '.'
    dir: 'backend/user-service'
  
  # Push Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - '--all-tags'
      - 'us-central1-docker.pkg.dev/vaulted-harbor-476903-t8/ecommerce-repo/user-service'
  
  # Deploy to GKE
  - name: 'gcr.io/cloud-builders/gke-deploy'
    args:
      - 'run'
      - '--filename=infrastructure/kubernetes/deployments/user-service-deployment.yaml'
      - '--image=us-central1-docker.pkg.dev/vaulted-harbor-476903-t8/ecommerce-repo/user-service:$BUILD_ID'
      - '--location=us-central1-a'
      - '--cluster=ecommerce-cluster'
      - '--namespace=ecommerce'

images:
  - 'us-central1-docker.pkg.dev/vaulted-harbor-476903-t8/ecommerce-repo/user-service:$BUILD_ID'
  - 'us-central1-docker.pkg.dev/vaulted-harbor-476903-t8/ecommerce-repo/user-service:latest'

timeout: 1200s
```

### Step 2: Create Cloud Build Triggers

```bash
# For user-service
gcloud builds triggers create github \
  --repo-name=gcp-three-tier-ecommerce-project \
  --repo-owner=rupesh9999 \
  --branch-pattern=main \
  --build-config=backend/user-service/cloudbuild.yaml \
  --included-files='backend/user-service/**' \
  --name=user-service-trigger

# For product-service
gcloud builds triggers create github \
  --repo-name=gcp-three-tier-ecommerce-project \
  --repo-owner=rupesh9999 \
  --branch-pattern=main \
  --build-config=backend/product-service/cloudbuild.yaml \
  --included-files='backend/product-service/**' \
  --name=product-service-trigger

# For order-service
gcloud builds triggers create github \
  --repo-name=gcp-three-tier-ecommerce-project \
  --repo-owner=rupesh9999 \
  --branch-pattern=main \
  --build-config=backend/order-service/cloudbuild.yaml \
  --included-files='backend/order-service/**' \
  --name=order-service-trigger

# For frontend
gcloud builds triggers create github \
  --repo-name=gcp-three-tier-ecommerce-project \
  --repo-owner=rupesh9999 \
  --branch-pattern=main \
  --build-config=frontend/cloudbuild.yaml \
  --included-files='frontend/**' \
  --name=frontend-trigger
```

### Step 3: Connect GitHub Repository

1. Go to: https://console.cloud.google.com/cloud-build/triggers
2. Click **Connect Repository**
3. Select **GitHub** → Authenticate
4. Select repository: `rupesh9999/gcp-three-tier-ecommerce-project`
5. Click **Connect**

## Recommended Approach

**Use Option 3 (Google Cloud Build)** because:

1. ✅ No need to customize Jenkins image
2. ✅ Native GCP integration
3. ✅ Automatic builds on push
4. ✅ Built-in logging and monitoring
5. ✅ Scales automatically
6. ✅ No tool installation required
7. ✅ Works out of the box with GKE

Jenkins can then be used for:
- Orchestration and approval gates
- Running tests
- Managing deployments across environments
- Integration with other systems

## Quick Start Commands

```bash
# 1. Create secret for GCP key
kubectl create secret generic jenkins-gcp-key \
  --from-file=key.json=./jenkins-key.json \
  -n jenkins

# 2. Enable Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# 3. Grant Cloud Build permissions
PROJECT_ID="vaulted-harbor-476903-t8"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/container.developer

# 4. Connect GitHub and create triggers (use Web UI - easier)
echo "Go to: https://console.cloud.google.com/cloud-build/triggers"
```

## Testing Your Pipeline

### Test with Cloud Build:

```bash
# Manual trigger
cd /home/ubuntu/gcp-three-tier-ecommerce-project
gcloud builds submit \
  --config backend/user-service/cloudbuild.yaml \
  backend/user-service/

# Check build status
gcloud builds list --limit=5

# View logs
gcloud builds log <BUILD_ID>
```

### Test with Jenkins:

1. Go to Jenkins UI: http://34.46.37.36/jenkins
2. Click on `user-service-pipeline`
3. Click **Build Now**
4. Monitor **Console Output**

## Troubleshooting

### Jenkins Pod Doesn't Have Tools

**Problem:** `gcloud: command not found`, `kubectl: command not found`, `docker: command not found`

**Solution:** Use Option 3 (Cloud Build) or Option 1 (Kubernetes Plugin with pre-built containers)

### Permission Denied Errors

**Problem:** Cannot push to Artifact Registry or deploy to GKE

**Solution:** Verify service account has correct roles:
```bash
gcloud projects get-iam-policy vaulted-harbor-476903-t8 \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:jenkins-gke@"
```

### GitHub Webhook Not Triggering

**Problem:** Push to GitHub doesn't trigger build

**Solution:**
1. Go to GitHub repo → Settings → Webhooks
2. Add webhook: http://34.46.37.36/jenkins/github-webhook/
3. Content type: `application/json`
4. Events: Just the push event
5. Active: ✓

## Next Steps

1. **Choose your approach** (I recommend Option 3: Cloud Build)
2. **Create cloudbuild.yaml files** for all services
3. **Set up Cloud Build triggers** via Web UI
4. **Test with a commit** to verify automation
5. **Add approval gates** in Jenkins if needed
6. **Set up monitoring** with Cloud Monitoring

## Support

If you need help with any step, refer to:
- GCP Cloud Build: https://cloud.google.com/build/docs
- Jenkins Kubernetes Plugin: https://plugins.jenkins.io/kubernetes/
- GKE CI/CD Best Practices: https://cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build
