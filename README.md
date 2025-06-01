check mt gitlab: this is ass


# Nemi Demo Infrastructure

This repository contains infrastructure configuration for a demo AWS architecture using EC2, RDS, and Auto Scaling within a VPC. This setup includes both public and private subnets, load balancer, internet gateway, and security considerations.


<img width="482" alt="image" src="https://github.com/user-attachments/assets/cabf66b7-c32f-4ba4-af2f-e0d19104df4d" />


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
terraform init  
terraform apply
 <!-- when you first apply the resources,in the folder .terraform/netowrking..,
 these will be file that has unexpected variable, just track the error log, delete it and apply again -->
terraform destroy -- to destroy infra
```
## Dev/test enviroment



````md
---

## 🧪 Dev/Test Environment (Terraform)

To test in a development environment using Terraform, follow these steps:

1. **Enable DNS Hostnames and DNS Resolution for the VPC**

```hcl
resource "aws_vpc" "main" {
  # ... existing config ...

  enable_dns_hostnames = true
  enable_dns_support   = true
}
````

2. **Place RDS and EC2 instances in Public Subnets** (for dev/testing only)

Make sure your Terraform subnet resources for dev/test include public subnets, e.g.:

```hcl
resource "aws_subnet" "public" {
  cidr_block = "10.0.4.0/24"
  vpc_id     = aws_vpc.main.id
  map_public_ip_on_launch = true
  # ... other settings ...
}
```

Update EC2 and RDS resources to use these public subnets.

3. **Enable Public Access on RDS**

Add or modify your RDS resource like this:

```hcl
resource "aws_db_instance" "example" {
  # ... existing config ...

  publicly_accessible = true
  # ensure security groups allow inbound access on DB port
}
```

4. **Add Inbound Security Group Rules**

Example to allow SSH and database access from your IP:

```hcl
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["YOUR.IP.ADDRESS/32"]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "allow_db_access" {
  type              = "ingress"
  from_port         = 3306 # or 5432 for PostgreSQL
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ec2.id
}
```
or add in the console
finally, try to ssh in the instance

![Screenshot 2025-05-25 170837](https://github.com/user-attachments/assets/23f562cb-8e0b-49c9-8344-e26eacee3476)
5. **Important Notes**

* Use these changes **only in development or test environments**.
* Revert to private subnets and disable public access in production.
