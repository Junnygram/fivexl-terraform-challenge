# FivexL Terraform Challenge - Website Hosting on AWS

## The Challenge
Provision infrastructure to host a website on AWS using Terraform, demonstrating best practices, redundancy, and multi-account support.

## Selected Hosting Strategies

I have chosen the following two methods for hosting the website:

### 1. Serverless Static Hosting (S3 + CloudFront)
**Why:**
- **Cost-Effective:** Pay only for storage and egress.
- **Performance:** CloudFront caches content globally near users (CDN).
- **Simplicity:** No servers to manage or patch.
- **Scalability:** Handles virtually unlimited traffic automatically.
- **Security:** S3 can be private, accessible only via CloudFront (OAI/OAC). TLS is native.

### 2. Traditional IaaS (EC2 + Application Load Balancer)
**Why:**
- **Control:** Full control over the OS and web server configuration (Nginx/Apache).
- **Flexibility:** Can easily evolve into a dynamic application server if requirements change.
- **Demonstration:** Showcases capability to manage VPCs, Security Groups, Auto Scaling Groups (ASG), and Load Balancers.
- **Availability:** Using an ALB and ASG across multiple Availability Zones ensures high availability.

### Rejected Alternatives
- **AWS Amplify / Elastic Beanstalk:** While easy to set up, these abstract away the underlying infrastructure. For a Terraform challenge, explicit resource management demonstrates better understanding of the cloud.
- **EKS / ECS (Containers):** Excellent for microservices, but significant operational overhead (control plane cost, complexity) for a simple static website. Over-engineering for this specific requirement.
- **Lightsail:** Great for quick projects but lacks the granular "Infrastructure as Code" control and integration capabilities of native AWS services tailored for enterprise scenarios.

## Architecture

### System Diagram
```mermaid
graph TD
    User((User)) -->|HTTPS| CloudFront[CloudFront CDN]
    User -->|HTTP| ALB[Application Load Balancer]
    
    subgraph "Strategy A: Static"
    CloudFront -->|OAC| S3[S3 Bucket\n(Unqiue Content)]
    end
    
    subgraph "Strategy B: Dynamic (VPC)"
        ALB -->|Target Group| ASG[Auto Scaling Group]
        subgraph "AZ 1"
            ASG --> EC2_1[EC2 Instance]
        end
        subgraph "AZ 2"
            ASG --> EC2_2[EC2 Instance]
        end
    end
```

### Directory Structure
```
.
├── src/                # Website content (HTML/CSS)
├── terraform/
│   ├── modules/        # Reusable Terraform modules
│   │   ├── s3-site/    # Module for S3+CloudFront
│   │   └── ec2-site/   # Module for EC2+ALB
│   └── live/           # Environment instantiations
│       ├── dev/
│       └── prod/
└── .github/            # CI/CD Workflows
```

## Requirements Coverage
- **Terraform Infrastructure:** 100% Terraform.
- **Remote State:** Configured using S3 Backend + DynamoDB locking.
- **Auto Redeployment:** GitHub Actions pipeline triggers on changes.
- **Stable Endpoints:** CloudFront Distribution URL and ALB DNS name remain static.
- **Multi-Account:** `live/dev` and `live/prod` separate configurations.
