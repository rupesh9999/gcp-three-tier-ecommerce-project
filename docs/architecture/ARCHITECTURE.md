# E-Commerce Application Architecture

## Architecture Overview

This document describes the three-tier architecture of our e-commerce platform deployed on Google Cloud Platform.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION TIER                                  │
│                                                                               │
│  ┌──────────────┐         ┌──────────────┐         ┌──────────────┐        │
│  │   React App  │────────▶│  Cloud CDN   │────────▶│  Cloud       │        │
│  │  (Frontend)  │         │              │         │  Storage     │        │
│  └──────────────┘         └──────────────┘         └──────────────┘        │
│         │                        │                                           │
└─────────┼────────────────────────┼───────────────────────────────────────────┘
          │                        │
          │                        ▼
┌─────────┼──────────────────────────────────────────────────────────────────┐
│         │              INTEGRATION & MESSAGING TIER                         │
│         │                                                                   │
│         │         ┌────────────────────┐         ┌──────────────────┐     │
│         └────────▶│  API Gateway       │────────▶│  Google Pub/Sub  │     │
│                   │  (REST/GraphQL)    │         │  (Message Queue) │     │
│                   └────────────────────┘         └──────────────────┘     │
│                            │                              │                 │
└────────────────────────────┼──────────────────────────────┼────────────────┘
                             │                              │
                             ▼                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      APPLICATION/BUSINESS LOGIC TIER                         │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    Google Kubernetes Engine (GKE)                    │   │
│  │                                                                       │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────┐ │   │
│  │  │    User      │  │   Product    │  │    Order     │  │ Notif.  │ │   │
│  │  │   Service    │  │   Service    │  │   Service    │  │ Service │ │   │
│  │  │ (Spring Boot)│  │(Spring Boot) │  │(Spring Boot) │  │(Spring) │ │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └─────────┘ │   │
│  │                                                                       │   │
│  └───────────────────────────────────────────────────────────────────┬─┘   │
│                                                                        │     │
└────────────────────────────────────────────────────────────────────────┼────┘
                                                                         │
                                                                         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA TIER                                       │
│                                                                               │
│  ┌──────────────┐         ┌──────────────┐         ┌──────────────┐        │
│  │ PostgreSQL   │         │ Elasticsearch│         │    Redis     │        │
│  │  (Primary)   │         │   (Search)   │         │   (Cache)    │        │
│  └──────────────┘         └──────────────┘         └──────────────┘        │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────┬─┘
                                                                             │
                                                                             ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE & DEVOPS LAYER                             │
│                                                                               │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │ Terraform  │  │  Jenkins   │  │  ArgoCD    │  │ SonarQube  │           │
│  │   (IaC)    │  │   (CI)     │  │  (GitOps)  │  │ (Quality)  │           │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘           │
│                                                                               │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │ Prometheus │  │  Grafana   │  │    VPC     │  │    IAM     │           │
│  │ (Metrics)  │  │(Dashboards)│  │(Networking)│  │  (Access)  │           │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘           │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Presentation Tier

#### React Frontend
- **Technology**: React 18 with TypeScript, Redux for state management
- **Components**:
  - Product Catalog (listing, filtering, sorting)
  - Product Details (images, description, reviews)
  - Shopping Cart (add, remove, update quantities)
  - Checkout Flow (shipping, payment)
  - User Dashboard (orders, profile, wishlist)
  - Authentication (login, register, password reset)

#### Google Cloud CDN
- **Purpose**: Edge caching for static assets and API responses
- **Configuration**:
  - Origin: Cloud Storage bucket
  - Cache TTL: 3600s for static assets, 60s for API responses
  - HTTPS enforcement
  - Custom domain with SSL certificate

#### Google Cloud Storage
- **Buckets**:
  - `frontend-static-assets`: React build files
  - `product-images`: Product photos and media
  - `user-uploads`: User-generated content
- **Access**: Public read for static assets, authenticated for uploads

### 2. Integration & Messaging Tier

#### Google Cloud API Gateway
- **Configuration**:
  - OpenAPI 3.0 specification
  - JWT authentication via Firebase Auth or custom OAuth2
  - Rate limiting: 1000 req/min per client
  - CORS policies for frontend domains
  - Request/response transformation
- **Routes**:
  - `/api/v1/users/*` → User Service
  - `/api/v1/products/*` → Product Service
  - `/api/v1/orders/*` → Order Service
  - `/api/v1/notifications/*` → Notification Service

#### Google Pub/Sub
- **Topics**:
  - `order-created`: New order events
  - `order-updated`: Order status changes
  - `payment-processed`: Payment confirmations
  - `notification-requested`: Email/SMS triggers
  - `inventory-updated`: Stock level changes
- **Subscriptions**:
  - Push subscriptions to backend services
  - Pull subscriptions for batch processing
  - Dead-letter topics for failed messages (max retries: 5)
- **Message Format**: JSON with schema validation

### 3. Application/Business Logic Tier

#### Microservices Architecture on GKE

##### User Service
- **Responsibilities**:
  - User registration and authentication
  - Profile management
  - Address book
  - Password reset and email verification
- **Endpoints**:
  - `POST /api/v1/users/register`
  - `POST /api/v1/users/login`
  - `GET /api/v1/users/{id}`
  - `PUT /api/v1/users/{id}`
  - `GET /api/v1/users/{id}/orders`
- **Database**: PostgreSQL (users, addresses, auth_tokens)

##### Product Service
- **Responsibilities**:
  - Product catalog management
  - Category and brand management
  - Inventory tracking
  - Product search and filtering
  - Reviews and ratings
- **Endpoints**:
  - `GET /api/v1/products`
  - `GET /api/v1/products/{id}`
  - `POST /api/v1/products` (admin)
  - `PUT /api/v1/products/{id}` (admin)
  - `GET /api/v1/products/search?q={query}`
- **Database**: PostgreSQL (products, categories, inventory)
- **Search**: Elasticsearch (indexed product data)

##### Order Service
- **Responsibilities**:
  - Shopping cart management
  - Order creation and processing
  - Payment integration
  - Order status tracking
  - Invoice generation
- **Endpoints**:
  - `POST /api/v1/orders`
  - `GET /api/v1/orders/{id}`
  - `GET /api/v1/orders/user/{userId}`
  - `PUT /api/v1/orders/{id}/status`
  - `POST /api/v1/cart/items`
- **Database**: PostgreSQL (orders, order_items, payments)
- **Messaging**: Publishes to Pub/Sub topics

##### Notification Service
- **Responsibilities**:
  - Email notifications (order confirmation, shipping updates)
  - SMS alerts (order status, promotions)
  - Push notifications (mobile app integration)
- **Integration**:
  - SendGrid/AWS SES for email
  - Twilio for SMS
  - Firebase Cloud Messaging for push
- **Messaging**: Subscribes to Pub/Sub topics

#### GKE Cluster Configuration
- **Node Pools**:
  - Default pool: n1-standard-2 (2 vCPU, 7.5 GB RAM)
  - Autoscaling: 2-10 nodes
- **Namespaces**:
  - `production`: Production services
  - `staging`: Staging environment
  - `monitoring`: Prometheus, Grafana
- **Resource Limits**:
  - CPU requests: 250m, limits: 1000m
  - Memory requests: 512Mi, limits: 2Gi
- **Health Checks**:
  - Liveness probes: HTTP GET /actuator/health
  - Readiness probes: HTTP GET /actuator/health/readiness

### 4. Data Tier

#### PostgreSQL
- **Version**: PostgreSQL 15
- **Configuration**:
  - Multi-AZ deployment for high availability
  - Automated backups (daily, 7-day retention)
  - Read replicas for scaling reads
  - Connection pooling: PgBouncer
- **Schemas**:
  - `users`: User accounts and authentication
  - `products`: Product catalog and inventory
  - `orders`: Orders and transactions
  - `audit`: Audit logs
- **Indexes**: B-tree on primary keys, GIN for JSONB columns

#### Elasticsearch
- **Version**: Elasticsearch 8.x
- **Configuration**:
  - 3-node cluster for reliability
  - Index: `products` with custom analyzers
  - Mappings: Full-text search on name, description, tags
  - Aggregations: Faceted search (categories, price ranges, ratings)
- **Sync Strategy**: 
  - Real-time indexing via Logstash or custom sync service
  - Bulk API for initial data load

#### Redis
- **Version**: Redis 7.x
- **Use Cases**:
  - Session storage (user sessions)
  - API response caching (product lists, popular items)
  - Rate limiting counters
  - Shopping cart temporary storage
- **Configuration**:
  - Redis Cluster for horizontal scaling
  - TTL policies: 1 hour for sessions, 5 minutes for cache
  - Persistence: AOF with fsync every second

### 5. Infrastructure & DevOps Layer

#### Networking (VPC)
- **VPC Structure**:
  - CIDR: 10.0.0.0/16
  - Subnets:
    - Public subnet: 10.0.1.0/24 (NAT Gateway, Load Balancer)
    - Private subnet: 10.0.10.0/24 (GKE nodes)
    - Database subnet: 10.0.20.0/24 (PostgreSQL, Redis, Elasticsearch)
- **Firewall Rules**:
  - Allow HTTPS (443) from internet to Load Balancer
  - Allow HTTP (80) redirected to HTTPS
  - Allow internal communication within VPC
  - Deny all inbound by default
- **Cloud NAT**: For private subnet internet access
- **Cloud Load Balancer**: HTTPS load balancer with SSL termination

#### IAM
- **Service Accounts**:
  - `gke-cluster-sa`: GKE node permissions
  - `backend-services-sa`: Access to Cloud Storage, Pub/Sub, databases
  - `ci-cd-sa`: Jenkins and ArgoCD deployment permissions
- **Roles**:
  - Custom roles with least privilege principle
  - Workload Identity for GKE pod authentication

#### Terraform (IaC)
- **Modules**:
  - `vpc`: Network infrastructure
  - `gke`: Kubernetes cluster
  - `storage`: Cloud Storage buckets
  - `pubsub`: Topics and subscriptions
  - `databases`: Cloud SQL PostgreSQL
  - `iam`: Service accounts and roles
  - `monitoring`: Prometheus and Grafana setup
- **State Management**: Remote backend in Cloud Storage with state locking

#### Jenkins CI/CD
- **Pipeline Stages**:
  1. Code checkout from Git
  2. Run unit tests (JUnit for Java, Jest for React)
  3. SonarQube quality gate
  4. Build Docker images
  5. Push to Google Artifact Registry
  6. Update Kubernetes manifests
  7. Trigger ArgoCD sync
- **Credentials**: Stored in Jenkins credentials manager
- **Webhooks**: GitHub/GitLab webhooks for automatic triggers

#### ArgoCD (GitOps)
- **Repository**: Git repo with Kubernetes manifests
- **Applications**:
  - `user-service-prod`
  - `product-service-prod`
  - `order-service-prod`
  - `notification-service-prod`
  - `frontend-prod`
- **Sync Strategy**: Automated sync on Git commit
- **Health Checks**: Monitor pod status and readiness

#### SonarQube
- **Quality Gates**:
  - Code coverage > 80%
  - No critical vulnerabilities
  - Maintainability rating A
  - Security hotspots reviewed
- **Integration**: Jenkins plugin for automatic analysis

#### Prometheus & Grafana
- **Prometheus**:
  - Service discovery for Kubernetes pods
  - Metrics: CPU, memory, request rate, latency, error rate
  - Scrape interval: 15 seconds
  - Retention: 15 days
  - Alerting rules: High error rate, pod restarts, CPU throttling
- **Grafana**:
  - Dashboards: Cluster overview, service metrics, business KPIs
  - Data source: Prometheus
  - Alerting: Email and Slack notifications
  - Pre-built dashboards: Node Exporter, Spring Boot, PostgreSQL

## Data Flow

### User Registration Flow
1. User submits registration form in React app
2. Request goes through Cloud CDN → API Gateway
3. API Gateway validates JWT and routes to User Service
4. User Service validates data and creates record in PostgreSQL
5. Confirmation email event published to Pub/Sub
6. Notification Service processes message and sends email
7. Response returned to frontend

### Product Search Flow
1. User enters search query in React app
2. Request: React → API Gateway → Product Service
3. Product Service queries Elasticsearch
4. Results cached in Redis for 5 minutes
5. Response: Product Service → API Gateway → React
6. React renders product cards

### Order Creation Flow
1. User completes checkout in React app
2. Request: React → API Gateway → Order Service
3. Order Service:
   - Creates order record in PostgreSQL
   - Publishes `order-created` event to Pub/Sub
   - Returns order confirmation
4. Inventory Service (subscriber) decrements stock
5. Notification Service (subscriber) sends confirmation email
6. Payment Service (subscriber) processes payment
7. Order Service updates status based on payment result

## Security Architecture

### Authentication & Authorization
- **JWT Tokens**: Issued by User Service, validated by API Gateway
- **Token Structure**:
  - Header: Algorithm (RS256)
  - Payload: userId, email, roles, exp (1 hour)
  - Signature: RSA private key
- **Refresh Tokens**: Stored in secure HTTP-only cookies (7 days)
- **RBAC**: Roles: CUSTOMER, ADMIN, SUPPORT

### Data Security
- **Encryption at Rest**: GCP default encryption for all storage
- **Encryption in Transit**: TLS 1.3 for all communications
- **Secrets Management**: Kubernetes Secrets (encrypted with KMS)
- **PII Protection**: Password hashing (bcrypt), credit card tokenization

### Network Security
- **Web Application Firewall**: Cloud Armor rules
- **DDoS Protection**: Cloud Armor DDoS protection
- **Private Connectivity**: Private Service Connect for databases
- **IP Whitelisting**: Admin endpoints restricted to corporate IPs

## Scalability & Performance

### Horizontal Scaling
- **GKE Autoscaling**: HPA based on CPU (target: 70%) and custom metrics
- **Database Scaling**: Read replicas for read-heavy operations
- **Cache Layer**: Redis for reducing database load
- **CDN**: Global edge locations for static content

### Performance Optimization
- **Database Indexing**: Optimized indexes on frequently queried columns
- **Connection Pooling**: HikariCP with max pool size 20
- **Lazy Loading**: JPA lazy fetching strategies
- **Pagination**: Limit query results (max 100 per page)
- **Compression**: Gzip compression for API responses

## Disaster Recovery & High Availability

### Backup Strategy
- **PostgreSQL**: Automated daily backups, 7-day retention, point-in-time recovery
- **Elasticsearch**: Snapshot to Cloud Storage (daily)
- **Redis**: AOF persistence with fsync every second
- **Application State**: Stateless services, no local state

### High Availability
- **Multi-Zone Deployment**: GKE cluster across 3 zones
- **Database Replication**: PostgreSQL with synchronous replication
- **Load Balancing**: Health check-based traffic routing
- **Circuit Breaker**: Resilience4j for fault tolerance
- **Retry Logic**: Exponential backoff for transient failures

### Monitoring & Alerting
- **Uptime Monitoring**: Cloud Monitoring uptime checks (1-minute interval)
- **Log Aggregation**: Cloud Logging with log-based metrics
- **Alerting Rules**:
  - Service down for > 1 minute
  - Error rate > 5% for 5 minutes
  - Response latency > 1s (p95) for 10 minutes
  - Database connection pool exhaustion
  - Disk usage > 80%
- **Notification Channels**: Email, Slack, PagerDuty

## Cost Optimization

- **GKE Autopilot**: Automatic resource optimization
- **Preemptible VMs**: For non-critical batch jobs
- **Cloud CDN**: Reduce origin traffic
- **Committed Use Discounts**: 1-year commitment for predictable workloads
- **Storage Lifecycle**: Archive old backups to Nearline/Coldline
- **Resource Quotas**: Prevent runaway costs

## Compliance & Governance

- **Audit Logging**: Cloud Audit Logs for all API calls
- **Data Residency**: Region-specific deployments (us-central1)
- **GDPR Compliance**: User data export and deletion APIs
- **PCI DSS**: Payment processing via third-party gateway (Stripe)
- **SOC 2**: GCP inherits compliance, application-level controls

## Future Enhancements

- [ ] Multi-region deployment for global customers
- [ ] GraphQL API alongside REST
- [ ] Machine learning for product recommendations
- [ ] Real-time inventory tracking with WebSockets
- [ ] Mobile apps (iOS, Android) with shared backend
- [ ] A/B testing framework for feature experimentation
- [ ] Serverless functions for event processing (Cloud Functions)
- [ ] Service mesh (Istio) for advanced traffic management
