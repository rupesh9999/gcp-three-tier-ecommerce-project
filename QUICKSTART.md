# E-Commerce Platform - Quick Start Guide

This guide will help you get the e-commerce platform running locally in under 10 minutes.

## Prerequisites

Ensure you have installed:
- Docker Desktop (with Docker Compose)
- Git

## Quick Start (Local Development)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd gcp-three-tier-ecommerce-project
```

### 2. Start All Services with Docker Compose

```bash
# Start all services in detached mode
docker-compose up -d

# View logs
docker-compose logs -f
```

This will start:
- PostgreSQL database (port 5432)
- Redis cache (port 6379)
- Elasticsearch (port 9200)
- User Service backend (port 8081)
- Frontend React app (port 3000)

### 3. Wait for Services to be Healthy

```bash
# Check service status
docker-compose ps

# Wait until all services show as "healthy"
```

### 4. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8081/api/v1
- **API Health**: http://localhost:8081/api/v1/actuator/health
- **Elasticsearch**: http://localhost:9200

### 5. Test the Application

#### Register a New User

```bash
curl -X POST http://localhost:8081/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "password": "SecurePass123"
  }'
```

#### Login

```bash
curl -X POST http://localhost:8081/api/v1/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePass123"
  }'
```

Save the `accessToken` from the response.

#### Get Current User

```bash
curl http://localhost:8081/api/v1/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 6. Pre-loaded Test Accounts

The following accounts are available for testing:

| Email | Password | Roles |
|-------|----------|-------|
| admin@example.com | Admin123! | ROLE_ADMIN, ROLE_USER |
| john.doe@example.com | Admin123! | ROLE_USER |
| jane.smith@example.com | Admin123! | ROLE_USER |

### 7. Stop All Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (deletes all data)
docker-compose down -v
```

## Development Workflow

### Backend Development

```bash
# Run only backend services
docker-compose up -d postgres redis elasticsearch

# Navigate to backend service
cd backend/user-service

# Run service locally for development
mvn spring-boot:run
```

### Frontend Development

```bash
# Install dependencies
cd frontend
npm install

# Start development server with hot reload
npm start

# Run tests
npm test

# Build for production
npm run build
```

### Database Access

```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U postgres -d postgres

# List all tables
\dt

# Query users
SELECT * FROM users;

# Exit
\q
```

### Redis Access

```bash
# Connect to Redis CLI
docker-compose exec redis redis-cli

# Check keys
KEYS *

# Exit
exit
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f user-service
docker-compose logs -f frontend

# Last 100 lines
docker-compose logs --tail=100 user-service
```

## Troubleshooting

### Port Already in Use

If you see "port already allocated" errors:

```bash
# Check what's using the port (example for 8081)
lsof -i :8081

# Kill the process
kill -9 <PID>

# Or change the port in docker-compose.yml
```

### Services Not Starting

```bash
# Remove all containers and volumes
docker-compose down -v

# Rebuild images
docker-compose build --no-cache

# Start again
docker-compose up -d
```

### Database Connection Errors

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check logs
docker-compose logs postgres

# Restart PostgreSQL
docker-compose restart postgres
```

### Clear All Data

```bash
# Stop and remove everything including volumes
docker-compose down -v

# Remove all unused Docker resources
docker system prune -a --volumes
```

## Next Steps

After successfully running locally:

1. **Read the Full Documentation**: [docs/runbook/RUNBOOK.md](docs/runbook/RUNBOOK.md)
2. **Setup GCP**: Follow the GCP setup section in the runbook
3. **Deploy with Terraform**: Provision infrastructure on GCP
4. **Configure CI/CD**: Setup Jenkins and ArgoCD pipelines
5. **Deploy to Production**: Follow the deployment guide

## Additional Resources

- **Architecture Documentation**: [docs/architecture/ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md)
- **API Documentation**: http://localhost:8081/api/v1/swagger-ui.html (when running)
- **Frontend README**: [frontend/README.md](frontend/README.md)
- **Backend README**: [backend/user-service/README.md](backend/user-service/README.md)

## Support

For issues or questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review logs: `docker-compose logs -f`
- Create an issue in the repository
