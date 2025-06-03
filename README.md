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
    

  ## 🧪 Environment Deployment Strategy (via GitLab CI/CD)

  This infrastructure is deployed based on Git branch context:

  - **`dev` branch** → Provision development/test infrastructure
  - **`pro` branch** → Provision production infrastructure

  ### Branch-specific Deployment Behavior

  - **Development Environment (`dev` branch)**:
    - EC2 and RDS are launched in **public subnets**
    - RDS is marked as `publicly_accessible = true`
    - EC2 instances receive public IPs for direct SSH access
    - Security groups allow inbound access from developer IPs (e.g., SSH, DB ports)

  - **Production Environment (`pro` branch)**:
    - All resources are deployed in **private subnets**
    - No public IPs are assigned
    - Access is routed through Load Balancer and NAT Gateway
    - RDS is private and only accessible within VPC

  > This branch-based strategy ensures isolation and appropriate security for each environment.  
  > GitLab CI/CD `.gitlab-ci.yml` should define different jobs or Terraform workspaces depending on the current branch.

  ---
  5. **Important Notes**

  * Use these changes **only in development or test environments**.
  * Revert to private subnets and disable public access in production.


  ## 🌐 Domain Configuration with Route 53 and ALB

  Once the infrastructure is up and running, and your Java project is successfully deployed inside the EC2 instance using Docker, the next step is to expose the application to the internet using a custom domain.

  ### ✅ Prerequisites

  - Infrastructure has been provisioned via Terraform
  - EC2 instances are active, Docker is installed, and your Java project is running inside containers
  - A domain name has been purchased (e.g., via Namecheap, GoDaddy, or AWS Route 53)

  ---

  ### 🧭 Step 1: Create a Hosted Zone in Route 53

  Go to AWS Route 53 and create a **public hosted zone** for your domain (e.g., `fbnemi.xyz`).

  - AWS will automatically generate **NS (Name Server)** records.
  - You will need to copy these values.

 ![image](https://github.com/user-attachments/assets/267e3b96-e890-4f83-8601-e8501b215faa)


  ---

  ### 🔁 Step 2: Update NS Records at Domain Registrar (e.g., Namecheap)

  Go to your domain provider (e.g., Namecheap), and update the **Nameserver settings** to match the NS records from Route 53.

  - Set **custom DNS**
  - Paste all 4 AWS name servers exactly as provided

  ---

  ### 🧩 Step 3: Add a Subdomain Record for the Application Load Balancer (ALB)

  Back in Route 53, inside your hosted zone, create a new **A record (Alias)** or **CNAME** for your subdomain.

  - Example:
    - **Record name**: `test.fbnemi.xyz`
    - **Type**: A (Alias to Application Load Balancer)
    - **Alias target**: Select the ALB from your region
    - **Routing policy**: Simple

  ![image](https://github.com/user-attachments/assets/52b877f5-2c53-4c82-aab7-ccce0eec0aef)


  ---

  ### ✅ Verification

  At this stage, if your infrastructure has been successfully provisioned and the application is properly deployed, you should be able to access your API using one of the following methods:

  - Directly via **EC2 public IP** (only available in `dev` environment)
    ```
    http://<EC2_PUBLIC_IP>:<PORT>
    ```

![image](https://github.com/user-attachments/assets/2469f71f-08d0-4869-becd-bf9a59856d7c)


  - Through the **Application Load Balancer DNS**
    ```
    http://<ALB_DNS_NAME>
    ```
 ![image](https://github.com/user-attachments/assets/007f5db9-8ac9-4ea8-9635-d43473e82a15)




  - Using your custom **domain name** (e.g., `test.fbnemi.xyz`) if DNS and ALB routing are correctly configured
    ```
    http://test.fbnemi.xyz
    ```

  If the application is not reachable, double-check:
  - Security groups allow inbound HTTP/HTTPS traffic
  - ALB target group health checks are passing
  - The domain is pointing to the correct ALB alias

  ---
  ### 🔄 Step 4: Switch from HTTP to HTTPS

  To secure your API with HTTPS, follow these steps to configure SSL using AWS Certificate Manager (ACM) and the Application Load Balancer (ALB):

  1. **Create a Certificate in ACM**
    - Go to **AWS Certificate Manager**
    - Request a **Public Certificate**
    - Enter your domain name (e.g., `test.fbnemi.xyz`)
    - Choose **DNS Validation**

![image](https://github.com/user-attachments/assets/9621c55c-3a6e-45b3-8cc2-84d6dcb19531)


  2. **Add the CNAME Record to Hosted Zone**
    - After submitting the request, ACM will provide a **CNAME record**
    - Go to **Route 53 → Hosted Zone**
    - Create a **CNAME record** exactly as specified by ACM
    - Wait until the certificate status in ACM becomes **Issued**



  3. **Add HTTPS Listener to ALB**
    - Go to **EC2 → Load Balancers**
    - Select your ALB → go to **Listeners** tab
    - Add a new listener:
      - **Protocol**: HTTPS
      - **Port**: 443
      - Choose the **ACM certificate**
      - Forward to your existing target group
  4. **Update Security Group to Allow HTTPS**
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

 ![image](https://github.com/user-attachments/assets/f6ef917f-faff-42ee-b1d0-faeda3f3d00f)


  Make sure to test and confirm that the certificate is active and the app loads correctly over HTTPS.



