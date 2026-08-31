# Terraform — Infrastructure as Code (IaC)

---

## Infrastructure as Code (IaC) Concepts

| Term | Meaning |
|------|---------|
| **IaC** | Managing infrastructure through code instead of manual processes |
| **Declarative** | You declare what you want, Terraform figures out how |
| **Imperative** | You specify exact steps to achieve a result |
| **Idempotent** | Running the same code multiple times produces the same result |
| **State** | Terraform tracks what it has created |
| **Provider** | Plugin that interacts with cloud/APIs (AWS, GCP, Azure) |

## Infrastructure as Code (IaC) Benefits

| Benefit | Explanation |
|---------|-------------|
| **Version Control** | Treat infrastructure like code |
| **Consistency** | Same config = same environment every time |
| **Automation** | Provision infrastructure automatically |
| **Review Process** | PR reviews for infrastructure changes |
| **Disaster Recovery** | Rebuild entire infrastructure from code |
| **Documentation** | Code documents your infrastructure |

## Terraform vs Other IaC Tools

| Tool | Type | Language | Approach |
|------|------|----------|----------|
| Terraform | Infrastructure | HCL | Declarative |
| Ansible | Configuration | YAML | Procedural |
| CloudFormation | AWS | JSON/YAML | Declarative |
| Pulumi | Infrastructure | Python/JS/Go | Programmatic |
| Chef | Configuration | Ruby | Procedural |

## What is Terraform?

Terraform is an open-source Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure using a declarative configuration language.

**Analogy:** Terraform is like a blueprint for your infrastructure — you describe what you want, and Terraform builds it.

## Why Terraform?

| Problem | Solution |
|---------|----------|
| Clicking in AWS console is slow | Write code to provision everything |
| Manual setups have errors | Code is consistent and repeatable |
| Need to rebuild infrastructure | One command recreates everything |
| Team collaboration | Code in Git, review changes |
| Track changes | Version control for infrastructure |


## Terraform Architecture

| Component | What it does |
|-----------|--------------|
| **Terraform Core** | Reads configuration and builds resource graph |
| **Providers** | Plugins to interact with APIs (AWS, GCP, Azure) |
| **State** | Tracks what resources exist |
| **State Backend** | Where state is stored (local, S3, etc.) |
| **Modules** | Collections of `.tf` files that can be called as a reusable unit |
| **Provisioners** | Plugins for running scripts on local or remote machines during resource creation |

---

## Terraform Core Concepts

| Term | Meaning |
|------|---------|
| **Terraform Block** | Required settings (terraform version, backend) |
| **Provider** | Plugin to interact with a platform (AWS, Azure, Docker) |
| **Resource** | A component of your infrastructure (EC2, VPC, S3) |
| **Data Source** | Read data from existing infrastructure |
| **State** | Actual infrastructure state vs. configuration |
| **Plan** | Preview of changes that Terraform will make |
| **Apply** | Execute the changes |
| **Destroy** | Remove all resources |
| **Module** | Reusable collection of resources |
| **Variable** | Parameterize your configuration |
| **Output** | Export values from your configuration |
| **Backend** | Where Terraform stores state |
| **Workspace** | Isolated state for different environments |

## Terraform Workflow

```
Write → Plan → Apply → Manage
```

| Step | Command | What it does |
|------|---------|--------------|
| 1 | `terraform init` | Initialize working directory |
| 2 | `terraform plan` | Preview changes |
| 3 | `terraform apply` | Apply changes |
| 4 | `terraform destroy` | Remove all resources |

---

## Installing Terraform

### Linux/WSL
```bash
# Download Terraform
wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip

# Unzip
unzip terraform_1.9.0_linux_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify
terraform version
```

### Windows
```bash
# Use Chocolatey
choco install terraform

# Verify Installation
terraform --version
```

## First Terraform Configuration (Local)

```bash
mkdir ~/terraform-demo
cd ~/terraform-demo
```

### main.tf (No cloud needed)

```hcl
# main.tf
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

# Use the local provider (no cloud needed)
provider "local" {}

# Create a local file
resource "local_file" "hello" {
  content  = "Hello, Terraform! This file was created by infrastructure as code."
  filename = "${path.module}/hello.txt"
}

# Generate a random string
resource "random_string" "random" {
  length  = 16
  special = false
  upper   = false
}

# Output the random string
output "random_id" {
  value = random_string.random.result
}

output "file_created" {
  value = "File created at ${local_file.hello.filename}"
}
```

### 4. Initialize and Apply

```bash
# Initialize Terraform (downloads providers)
terraform init

# See the execution plan
terraform plan

# Apply the changes
terraform apply

# Type "yes" when prompted
```

**Output:**
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
file_created = "File created at ./hello.txt"
random_id = "a1b2c3d4e5f6g7h8"
```

```bash
# Check the file was created
cat hello.txt
# Hello, Terraform! This file was created by infrastructure as code.

# See the state file
cat terraform.tfstate
```

### 5. Destroy Resources

```bash
# Destroy what we created
terraform destroy
# Type "yes"
```
---

## AWS with Terraform

### Set Up AWS Credentials
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
```

### aws-main.tf
```hcl
# aws-main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "terraform-vpc" }
}

# Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "terraform-subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "terraform-igw" }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "terraform-rt" }
}

# Route Table Association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Security Group
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg" }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
  EOF

  tags = { Name = "terraform-web-server" }
}

# Outputs
output "public_ip" {
  value = aws_instance.web.public_ip
}
```

### Deploy
```bash
terraform init
terraform plan
terraform apply
```

### Clean Up
```bash
terraform destroy
```

**⚠️ Always destroy to avoid AWS charges!**

---

## Variables

### variables.tf
```hcl
# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH"
  type        = string
  default     = "0.0.0.0/0"
}
```

### Use Variables in main.tf
```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  # ...
}
```

### Set Variables
```bash
# Command line
terraform apply -var="instance_type=t3.small"

# Environment variable
export TF_VAR_instance_type="t3.small"

# terraform.tfvars
cat > terraform.tfvars <<EOF
environment = "staging"
instance_type = "t3.small"
EOF

# Multiple variable files
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

---

## Outputs

### outputs.tf
```hcl
# outputs.tf
output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "web_url" {
  value = "http://${aws_instance.web.public_ip}"
}
```

### Commands
```bash
terraform output           # Show all outputs
terraform output public_ip # Show specific output
terraform output -json     # JSON format
```

---

## Data Sources

### data.tf
```hcl
# data.tf
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use in resource
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
}
```

---

## Remote State (Backend)

### Why Remote State?
- Shared with team
- Secure and backed up
- State locking prevents conflicts

### backend.tf
```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"  # Globally unique
    key            = "terraform-demo/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Set Up S3 + DynamoDB
```bash
# Create S3 bucket
aws s3 mb s3://your-terraform-state-bucket --region us-east-1
aws s3api put-bucket-versioning --bucket your-terraform-state-bucket --versioning-configuration Status=Enabled

# Create DynamoDB table
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Migrate
```bash
terraform init -migrate-state
```

---

## Modules (Reusable Infrastructure)

### Module Structure
```
modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── web-server/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

### VPC Module

**modules/vpc/main.tf**
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = var.vpc_name }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.vpc_name}-igw" }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "${var.vpc_name}-public-${count.index + 1}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.vpc_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

**modules/vpc/variables.tf**
```hcl
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "public_subnet_cidrs" { type = list(string) }
variable "availability_zones" { type = list(string) }
```

**modules/vpc/outputs.tf**
```hcl
output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
```

### Web Server Module

**modules/web-server/main.tf**
```hcl
resource "aws_security_group" "web" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  count = var.instance_count

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web.id]
  associate_public_ip_address = true
  user_data = var.user_data

  tags = { Name = "${var.name}-${count.index + 1}" }
}
```

**modules/web-server/variables.tf**
```hcl
variable "name" {}
variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "ami_id" {}
variable "instance_type" { default = "t2.micro" }
variable "instance_count" { default = 1 }
variable "allowed_ssh_cidr" { type = list(string) }
variable "user_data" { default = "" }
```

**modules/web-server/outputs.tf**
```hcl
output "instance_ids" { value = aws_instance.web[*].id }
output "public_ips" { value = aws_instance.web[*].public_ip }
```

### Using Modules

**root/main.tf**
```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr   = "10.0.0.0/16"
  vpc_name   = "demo-vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones  = ["us-east-1a", "us-east-1b"]
}

module "web_server" {
  source = "./modules/web-server"

  name       = "web"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  ami_id     = "ami-0c02fb55956c7d316"
  instance_count = 2
}
```

---

## Workspaces (Environments)

```bash
# Create workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspace
terraform workspace select dev

# List workspaces
terraform workspace list

# Apply in specific workspace
terraform workspace select dev
terraform apply
```

---

## Terraform Commands Summary

```bash
terraform init                    # Initialize directory
terraform init -migrate-state     # Migrate to remote state
terraform fmt                     # Format configuration files
terraform validate                # Validate configuration
terraform plan                    # Preview changes
terraform plan -out=tfplan        # Save plan to file
terraform apply                   # Apply changes
terraform apply tfplan            # Apply saved plan
terraform apply -auto-approve     # Skip confirmation
terraform destroy                 # Remove all resources
terraform destroy -auto-approve   # Skip confirmation
terraform show                    # Show current state
terraform state list              # List resources in state
terraform state show <resource>   # Show specific resource
terraform output                  # Show outputs
terraform output -json            # JSON format
terraform workspace new <name>    # Create workspace
terraform workspace list          # List workspaces
terraform workspace select <name> # Switch workspace
```

---

## Quick Interview Answers

**Q: What is Terraform?**
> "Terraform is an Infrastructure as Code tool that lets you define and provision infrastructure using declarative configuration files."

**Q: What is the difference between Terraform and Ansible?**
> "Terraform provisions infrastructure (servers, VPCs). Ansible configures them (installs packages, services)."

**Q: What is the Terraform state file?**
> "terraform.tfstate tracks the current infrastructure state, mapping configuration to actual resources."

**Q: What is the purpose of terraform plan?**
> "It shows what changes will be made before applying, so you can review them safely."

**Q: What is a provider in Terraform?**
> "A provider is a plugin that allows Terraform to interact with a platform like AWS, Azure, or Docker."

**Q: How do you manage multiple environments?**
> "Using workspaces, separate variable files (dev.tfvars, prod.tfvars), or separate directories."

**Q: What is the difference between local and remote state?**
> "Local state is stored on your machine. Remote state is stored in shared storage (S3) for team collaboration and locking."

---
