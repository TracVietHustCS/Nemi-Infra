Here's a complete and well-formatted `README.md` file written in English based on your diagram. It includes the project overview, requirements, how to set up, run, and test the infrastructure in a development environment.

---

````markdown
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
````

If using pre-defined Terraform templates:

```bash
terraform init
```

---

## 🚀 How to Run (Deploy)

1. **Provision VPC and subnets**
2. **Create Internet Gateway and route tables**
3. **Deploy the Load Balancer in Public Subnet**
4. **Create Launch Template and Auto Scaling Group for EC2 in Private Subnet**
5. **Provision RDS in Private Subnet group**
6. **Attach necessary security groups**

Using Terraform:

```bash
terraform apply
```

---

## 🧪 Development Testing Instructions

To test the infrastructure in a development environment:

### 1. Enable Public Access for RDS (for testing only)

* Go to **RDS Console > Databases > \[Your RDS instance]**
* Click **Modify**
* Set `Public access` to **Yes**
* Apply changes (may require restart)

### 2. Enable DNS Hostnames and DNS Resolution

* Go to **VPC Console > Your VPC**
* Ensure:

  * `Enable DNS Hostnames` = Yes
  * `Enable DNS Resolution` = Yes

### 3. Attach RDS and EC2 to Public Subnets (dev only)

* Temporarily move RDS and EC2 into public subnets (e.g. `10.0.4.0/24`)
* Ensure each instance has a public IP assigned

### 4. Add Inbound Rules to Security Groups

For **EC2 instance**:

* Allow SSH (`port 22`) from your IP
* Allow HTTP/HTTPS if serving a web app

For **RDS instance**:

* Add an inbound rule to allow traffic from the EC2 security group or:

  * Type: `PostgreSQL` / `MySQL` (based on DB)
  * Protocol: `TCP`
  * Port Range: `3306` / `5432`
  * Source: `EC2 security group` or your IP

Example (from CLI):

```bash
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxx \
    --protocol tcp \
    --port 3306 \
    --cidr YOUR.IP.ADDRESS/32
```

> ⚠️ **Warning:** Never enable public access in production.

---

## ✅ Verification

* Try SSH into EC2:

  ```bash
  ssh -i your-key.pem ec2-user@<Public-IP>
  ```
* From EC2, try connecting to RDS:

  ```bash
  mysql -h <RDS-ENDPOINT> -u <USER> -p
  ```
* Verify the load balancer DNS is accessible

---

## 🧼 Cleanup

When you're done testing:

```bash
terraform destroy
```

or manually delete resources via AWS Console.

---

## 📝 Notes

* Always secure your RDS and EC2 with proper security groups.
* Avoid public IPs or public access in production.
* Consider using bastion hosts and private DNS for real-world setups.

```

---

Let me know if you're using Terraform, CloudFormation, or plain AWS Console so I can add exact commands or examples for those.
```
