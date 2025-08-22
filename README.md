# 🚀 Nemi Demo Infrastructure

<div align="center">

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com/)
[![Java](https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white)](https://java.com/)
[![GitLab CI](https://img.shields.io/badge/gitlab%20ci-%23181717.svg?style=for-the-badge&logo=gitlab&logoColor=white)](https://gitlab.com/)
[![Route53](https://img.shields.io/badge/Route53-%23232F3E.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/route53/)

</div>

## 📋 Table of Contents

- [🏗 Architecture Overview](#-architecture-overview)
- [⚡ Tech Stack](#-tech-stack)
- [📋 Requirements](#-requirements)
- [🧪 Environment Deployment Strategy](#-environment-deployment-strategy-via-gitlab-cicd)
- [🔄 Recent Updates](#-update-summary-june-2025)
- [🔐 Security Configuration](#-updated-security-group-rules-for-ec2)
- [🌐 Domain Configuration](#-domain-configuration-with-route-53-and-alb)
- [🔒 HTTPS Configuration](#-step-4-switch-from-http-to-https)
- [🔑 IAM and Parameter Store](#-enhanced-iam-instance-profile)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [📞 Support](#-support)

---

This repository contains infrastructure configuration for a demo AWS architecture using EC2, RDS, and Auto Scaling within a VPC. This setup includes both public and private subnets, load balancer, internet gateway, and security considerations.

<img width="482" alt="AWS Architecture Diagram" src="https://github.com/user-attachments/assets/cabf66b7-c32f-4ba4-af2f-e0d19104df4d" />

---

## ⚡ Tech Stack

| Technology             | Purpose                                 | Icon |
| ---------------------- | --------------------------------------- | ---- |
| **AWS EC2**      | Virtual servers for application hosting | ☁️ |
| **AWS RDS**      | Managed database service                | 🗄️ |
| **AWS ALB**      | Application Load Balancer               | ⚖️ |
| **AWS Route 53** | DNS and domain management               | 🌐   |
| **Terraform**    | Infrastructure as Code                  | 🏗️ |
| **Docker**       | Container orchestration                 | 🐳   |
| **Java**         | Backend application development         | ☕   |
| **GitLab CI/CD** | Continuous integration and deployment   | 🚀   |
| **AWS ACM**      | SSL/TLS certificate management          | 🔐   |

## 🏗 Architecture Overview

- **Public Subnet** (`10.0.4.0/24`, `10.0.5.0/24`):
  
  - 🌐 Internet Gateway for outbound internet access
  - ⚖️ Load Balancer handling inbound HTTP/S traffic
- **Private Subnet** (`10.0.7.0/24`, `10.0.8.0/24`):
  
  - ☁️ EC2 Auto Scaling Group launched via Launch Template
  - 🗄️ Amazon RDS instance (DB subnet group)
  - 🔒 No direct internet access (only through NAT or Public IP in dev)

---

## 📋 Requirements

- ☁️ AWS CLI installed and configured
- 🏗️ Terraform or AWS CloudFormation (if using IaC)
- 🔑 IAM permissions to manage:
  - EC2
  - RDS
  - VPC and Subnets
  - Auto Scaling
  - Security Groups
- 🔐 Optional: SSH key pair for EC2 access

## 🧪 Environment Deployment Strategy (via GitLab CI/CD)

This infrastructure is deployed based on Git branch context:

- **`dev` branch** → 🧪 Provision development/test infrastructure
- **`pro` branch** → 🏭 Provision production infrastructure

### Branch-specific Deployment Behavior

- **Development Environment (`dev` branch)**:
  
  - 🌐 EC2 and RDS are launched in **public subnets**
  - 🔓 RDS is marked as `publicly_accessible = true`
  - 🖥️ EC2 instances receive public IPs for direct SSH access
  - 🔧 Security groups allow inbound access from developer IPs (e.g., SSH, DB ports)
- **Production Environment (`pro` branch)**:
  
  - 🔒 All resources are deployed in **private subnets**
  - 🚫 No public IPs are assigned
  - 🌐 Access is routed through Load Balancer and NAT Gateway
  - 🗄️ RDS is private and only accessible within VPC

> 💡 This branch-based strategy ensures isolation and appropriate security for each environment.
> 🚀 GitLab CI/CD `.gitlab-ci.yml` should define different jobs or Terraform workspaces depending on the current branch.

---

## 🔄 Update Summary (June 2025)

Recent updates have been made to enhance the infrastructure, improve security, and support backend/frontend routing:

### ✅ Key Infrastructure Changes

- **🚀 Launch Template Enhancements**:
  
  - Replaced hardcoded instance values with variables (`instance_type`, `key_name`)
  - Renamed `name_prefix` to `name = "dev-infra"` for clearer resource identity
- **⚖️ Application Load Balancer**:
  
  - Upgraded to version `~> 7.0` of the ALB Terraform module
  - Switched from `HTTP` listeners to full **HTTPS** support on port **443**
  - Integrated **🔐 ACM certificate** for secure communication
- **🎯 Multiple Target Groups**:
  
  - Defined two separate ALB target groups:
    - **Frontend (fe)** → Port **80**
    - **Backend (be)** → Port **8080**
  - Added **listener rule** to route `/client-api*` and `/public-api*` paths to the backend target group
- **🔒 Security Group Update**:
  
  - **New inbound rules** added to allow EC2 instances to receive traffic:
    - Port **80** and **8080**
    - **Source**: ALB Security Group
  - Ensures only the ALB can directly access EC2 services

---

## 🔐 Updated Security Group Rules (for EC2)

| Type       | Port | Source                 | Description                         |
| ---------- | ---- | ---------------------- | ----------------------------------- |
| HTTP       | 80   | ALB SG (`var.sg.lb`) | 🌐 Allow frontend traffic from ALB  |
| Custom TCP | 8080 | ALB SG (`var.sg.lb`) | ⚙️ Allow backend traffic from ALB |

---

## 🌐 Domain Configuration with Route 53 and ALB

Once the infrastructure is up and running, and your Java project is successfully deployed inside the EC2 instance using Docker, the next step is to expose the application to the internet using a custom domain.

### ✅ Prerequisites

- 🏗️ Infrastructure has been provisioned via Terraform
- ☁️ EC2 instances are active, Docker is installed, and your Java project is running inside containers
- 🌐 A domain name has been purchased (e.g., via Namecheap, GoDaddy, or AWS Route 53)

---

### 🧭 Step 1: Create a Hosted Zone in Route 53

Go to AWS Route 53 and create a **public hosted zone** for your domain (e.g., `fbnemi.xyz`).

- AWS will automatically generate **NS (Name Server)** records.
- You will need to copy these values.

![Route 53 Hosted Zone](https://github.com/user-attachments/assets/267e3b96-e890-4f83-8601-e8501b215faa)

---

### 🔁 Step 2: Update NS Records at Domain Registrar (e.g., Namecheap)

Go to your domain provider (e.g., Namecheap), and update the **Nameserver settings** to match the NS records from Route 53.

- Set **custom DNS**
- Paste all 4 AWS name servers exactly as provided(this is another demo, it do not match with for ns in step 1)

![Namecheap DNS Configuration](https://github.com/user-attachments/assets/f8b0e762-51bc-4825-8fe5-ea141a3fae91)

---

### 🧩 Step 3: Add a Subdomain Record for the Application Load Balancer (ALB)

Back in Route 53, inside your hosted zone, create a new **A record (Alias)** or **CNAME** for your subdomain.

- Example:
  - **Record name**: `test.fbnemi.xyz`
  - **Type**: A (Alias to Application Load Balancer)
  - **Alias target**: Select the ALB from your region
  - **Routing policy**: Simple

![Route 53 A Record Configuration](https://github.com/user-attachments/assets/52b877f5-2c53-4c82-aab7-ccce0eec0aef)

---

### ✅ Verification

At this stage, if your infrastructure has been successfully provisioned and the application is properly deployed, you should be able to access your API using one of the following methods:

- 🖥️ Directly via **EC2 public IP** (only available in `dev` environment)
  ```
  http://<EC2_PUBLIC_IP>:<PORT>
  ```

![EC2 Direct Access](https://github.com/user-attachments/assets/7652f8f0-0744-4901-9b11-be18e2d23cc6)

- ⚖️ Through the **Application Load Balancer DNS**
  ```
  http://<ALB_DNS_NAME>
  ```

![ALB DNS Access](https://github.com/user-attachments/assets/39fa29d8-a8ff-4dcf-bf9a-953d71f7a04d)

- 🌐 Using your custom **domain name** (e.g., `test.fbnemi.xyz`) if DNS and ALB routing are correctly configured
  ```
  http://test.fbnemi.xyz
  ```

If the application is not reachable, double-check:

- 🔒 Security groups allow inbound HTTP/HTTPS traffic
- 🎯 ALB target group health checks are passing
- 🌐 The domain is pointing to the correct ALB alias

---

### 🔒 Step 4: Switch from HTTP to HTTPS

To secure your API with HTTPS, follow these steps to configure SSL using AWS Certificate Manager (ACM) and the Application Load Balancer (ALB):

1. **🔐 Create a Certificate in ACM**
   - Go to **AWS Certificate Manager**
   - Request a **Public Certificate**
   - Enter your domain name (e.g., `test.fbnemi.xyz`)
   - Choose **DNS Validation**

![ACM Certificate Request](https://github.com/user-attachments/assets/8e05b963-d7f8-4903-bfdf-3e8cfc79a6bb)

2. **🌐 Add the CNAME Record to Hosted Zone**
   
   - After submitting the request, ACM will provide a **CNAME record**
   - Go to **Route 53 → Hosted Zone**
   - Create a **CNAME record** exactly as specified by ACM
   - OR you can click add to route 53 button in the console of the cname
   - Wait until the certificate status in ACM becomes **Issued**
3. **⚖️ Add HTTPS Listener to ALB**
   
   - Go to **EC2 → Load Balancers**
   - Select your ALB → go to **Listeners** tab
   - Add a new listener:
     - **Protocol**: HTTPS
     - **Port**: 443
     - Choose the **ACM certificate**
     - Forward to your existing target group
4. **🔒 Update Security Group to Allow HTTPS**
   
   - Go to the **Security Group** associated with your ALB
   - Add an inbound rule:
     - **Type**: HTTPS
     - **Port**: 443
     - **Source**: `0.0.0.0/0` (or restrict to specific IPs)

---

After this configuration, your app should be accessible securely at:

```
https://test.fbnemi.xyz
```

![HTTPS Access Verification](https://github.com/user-attachments/assets/5a9d0cde-8eb9-4a05-b333-5cebdedf7350)

Make sure to test and confirm that the certificate is active and the app loads correctly over HTTPS.

### 🔑 Enhanced IAM Instance Profile

This adds IAM role to EC2 so it can access parameters in AWS Systems Manager:

```terraform
module "iam_instance_profile" {
  source  = "terraform-in-action/iip/aws"
  actions = [
    "logs:*", 
    "rds:*",
    "ssm:GetParameter",
    "ssm:GetParameters",
    "ssm:GetParametersByPath",
    "kms:Decrypt"
  ]  
}
```

Also auto-create database password (secure string) when creating infrastructure:

```terraform
resource "aws_ssm_parameter" "my_secret" {
  name        = "/myapp/prod/db_password"  
  description = "Database password"
  type        = "SecureString"           
  value       = module.database.password         
}
```

### 🔧 Creating Parameters in AWS Systems Manager Parameter Store

Here's a step-by-step guide to create a parameter in AWS Systems Manager (SSM) Parameter Store via the AWS Console:

#### **1. 🌐 Open AWS Systems Manager**

- Log in to your **AWS Management Console**
- Navigate to **Systems Manager** (you can search for it in the services search bar)

#### **2. 📊 Go to Parameter Store**

- In the left sidebar, under **"Application Management"**, click **"Parameter Store"**

#### **3. ➕ Create a New Parameter**

- Click the **"Create parameter"** button at the top right

![Parameter Store Interface](https://github.com/user-attachments/assets/0224617a-5021-4308-a58a-abb699beda8f)

#### **4. 📝 Fill in Parameter Details**

| Field                    | Value                                                                      | Notes                                                         |
| ------------------------ | -------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **Name**           | `/app/env/parameter_name` (e.g., `/app/prod/db_password`)              | Use a hierarchical path for better organization               |
| **Description**    | (Optional) e.g., "Database password for production"                        | Helps identify the parameter later                            |
| **Tier**           | `Standard` (default) or `Advanced` (if > 4KB)                          | Advanced supports larger parameters                           |
| **Type**           | `String`, `StringList`, or `SecureString`                            | Use**SecureString** for sensitive data (like passwords) |
| **KMS Key Source** | (If SecureString) Choose `AWS managed key (default)` or your own KMS key | For encryption                                                |
| **Value**          | The actual value (e.g.,`MySecretPassword123!`)                           | For SecureString, this will be encrypted                      |

#### **5. 🏷️ (Optional) Add Tags**

- You can add tags (e.g., `Environment=Prod`, `Team=DevOps`) for better tracking.

#### **6. ✅ Create the Parameter**

- Click **"Create parameter"** at the bottom.

---

### **🖥️ How to Retrieve the Parameter in AWS CLI**

To fetch the parameter (e.g., in a startup script or Terraform):

```bash
# For plain String/StringList
aws ssm get-parameter --name "/app/prod/db_password" --query Parameter.Value --output text

# For SecureString (decrypts the value)
aws ssm get-parameter --name "/app/prod/db_password" --with-decryption --query Parameter.Value --output text
```

---

### **💡 Best Practices**

✔️ **Use hierarchical names** (e.g., `/app/prod/db_password`) for easy management.
✔️ **Restrict IAM access** to parameters using least-privilege policies.
✔️ **Use SecureString for secrets** (passwords, API keys).
✔️ **Rotate secrets regularly** (integrate with AWS Secrets Manager if needed).

---

## 🤝 Contributing

We welcome contributions to improve this infrastructure setup! Here's how you can contribute:

### 📋 Prerequisites

- Basic knowledge of AWS services and Terraform
- Understanding of Infrastructure as Code principles
- GitLab CI/CD experience (helpful)

### 🔄 Development Workflow

1. **🍴 Fork the Repository**
   
   ```bash
   git clone https://github.com/your-username/nemi-demo-infrastructure.git
   cd nemi-demo-infrastructure
   ```
2. **🌿 Create a Feature Branch**
   
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **🛠️ Make Your Changes**
   
   - Follow Terraform best practices
   - Update documentation for any new features
   - Test your changes in the `dev` environment
4. **✅ Test Your Changes**
   
   - Validate Terraform configurations: `terraform validate`
   - Run `terraform plan` to review changes
   - Ensure security groups and networking are properly configured
5. **📝 Submit a Pull Request**
   
   - Provide a clear description of your changes
   - Include any relevant screenshots or documentation updates
   - Reference any related issues

### 🎯 Areas for Contribution

- 🔒 **Security improvements**
- 📊 **Monitoring and logging enhancements**
- 🚀 **CI/CD pipeline optimizations**
- 📚 **Documentation improvements**
- 🧪 **Testing infrastructure additions**
- 💰 **Cost optimization suggestions**

### 📐 Code Standards

- Use consistent Terraform formatting (`terraform fmt`)
- Include proper variable descriptions and types
- Follow AWS resource naming conventions
- Add comments for complex configurations

---

## 📄 License

This project is licensed under the MIT License - see the details below:

```
MIT License

Copyright (c) 2025 Nemi Demo Infrastructure

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📞 Support

### 🆘 Getting Help

If you encounter any issues or have questions about this infrastructure setup:

1. **📖 Check the Documentation**: Review this README and inline code comments
2. **🔍 Search Issues**: Check existing GitHub issues for similar problems
3. **🐛 Report Bugs**: Create a new issue with detailed information
4. **💡 Feature Requests**: Open an issue with the "enhancement" label

### 📧 Contact Information

- **Project Maintainer**: Nemi Infrastructure Team
- **Email**: infrastructure@nemi-demo.com
- **Documentation**: [GitHub Wiki](https://github.com/your-org/nemi-demo-infrastructure/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-org/nemi-demo-infrastructure/issues)

### 🚨 Emergency Support

For production issues or security concerns:

- **Slack Channel**: `#infrastructure-alerts`
- **On-Call**: Contact DevOps team directly
- **AWS Support**: Use your AWS support plan for service-related issues

### 📚 Additional Resources

- 📖 [AWS Documentation](https://docs.aws.amazon.com/)
- 🏗️ [Terraform Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- 🐳 [Docker Documentation](https://docs.docker.com/)
- 🚀 [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)

---

<div align="center">

### 🌟 Star this repository if it helped you!

**Made with ❤️ by the Nemi Infrastructure Team**

</div>
