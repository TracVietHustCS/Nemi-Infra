# Nemi Demo Infrastructure

This repository contains infrastructure configuration for a demo AWS architecture using EC2, RDS, and Auto Scaling within a VPC. This setup includes both public and private subnets, load balancer, internet gateway, and security considerations.

---

## 🏗 Architecture Overview

- **Public Subnet** (`10.0.4.0/24`, `10.0.5.0/24`):
  - Internet Gateway for outbound internet access
  - Load Balancer handling inbound HTTP/S traffic

- **Private Subnet** (`10.0.7.0/24`, `10.0.8.0/24`):
  - EC2 Auto Scaling Group launched via Launch Template
  - Amazon RDS instance (DB subnet group)
  - No direct internet access (only through NAT or Public IP in dev)

---

## 📋 Requirements

- AWS CLI installed and configured
- Terraform or AWS CloudFormation (if using IaC)
- IAM permissions to manage:
  - EC2
  - RDS
  - VPC and Subnets
  - Auto Scaling
  - Security Groups
- Optional: SSH key pair for EC2 access

---

## 📥 Download

Clone this repository:

```bash
git clone https://github.com/your-username/nemi-demo-infra.git
cd nemi-demo-infra
