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

| Concept | What it does |
|---------|--------------|
| **Terraform Block** | Required settings (terraform version, backend) |
| **Provider** | Defines which cloud or service to interact with (AWS, GCP, etc.) |
| **Resource** | A single component to manage (EC2 instance, S3 bucket) |
| **Data Source** | Read existing infrastructure (not modify) |
| **State** | Tracks what Terraform has created |
| **Variables** | Parameterize your configuration |
| **Outputs** | Print values after apply (IP addresses, DNS names) |
| **Module** | Reusable block of Terraform code |
| **Plan** | Preview of changes before applying |


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

## Your First Terraform Configuration

### main.tf

```hcl
# Provider configuration
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Resource: Docker container running Nginx
resource "docker_container" "nginx" {
  image = "nginx:latest"
  name  = "terraform-nginx"
  ports {
    internal = 80
    external = 6767
  }
}
```

### Run it

```bash
terraform init
terraform plan
terraform apply
```

Now open `http://localhost:6767` — you'll see Nginx running!

---

## Your First Terraform Config — AWS

### main.tf

```hcl
# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration (set region)
provider "aws" {
  region = "us-east-1"
}

# EC2 instance resource
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-web-server"
  }
}

# Security group resource
resource "aws_security_group" "web_sg" {
  name        = "allow-ssh-http"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-web-sg"
  }
}
```

---

## Running Terraform

```bash
# Initialize the directory (downloads providers)
terraform init

# Format configuration files
terraform fmt

# Validate configuration
terraform validate

# See what changes will be made
terraform plan

# Apply the changes
terraform apply

# Destroy all resources
terraform destroy
```

---

## Terraform State

| Concept | Meaning |
|---------|---------|
| **terraform.tfstate** | File tracking your infrastructure |
| **terraform.tfstate.backup** | Backup of previous state |
| **Remote State** | Store state in S3, Azure, or Terraform Cloud |
| **State Locking** | Prevent concurrent modifications |

### Inspecting State

```bash
# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.web
```

---

## Variables

### variables.tf

```hcl
# Define variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
```

### Use variables in main.tf

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type

  tags = {
    Name        = "terraform-web-server"
    Environment = var.environment
  }
}
```

### Set variables

```bash
# Via command line
terraform apply -var="instance_type=t3.small"

# Via environment variable
export TF_VAR_instance_type="t3.small"

# Via terraform.tfvars file
# instance_type = "t3.small"
```

---

## Outputs

### outputs.tf

```hcl
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "instance_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = aws_instance.web.private_ip
}
```

---

## Data Sources

### data.tf

```hcl
# Get latest Amazon Linux 2 AMI
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
  instance_type = var.instance_type
}
```

---

## Provisioners (Post-creation setup)

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = "my-keypair"

  # Run commands after creation
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/my-keypair.pem")
      host        = self.public_ip
    }
  }

  # Copy files to instance
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/my-keypair.pem")
      host        = self.public_ip
    }
  }
}
```

---

## Modules

### Creating a module

```hcl
# modules/ec2/main.tf
variable "ami" {}
variable "instance_type" {}
variable "instance_name" {}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}

# outputs.tf
output "instance_id" {
  value = aws_instance.web.id
}
```

### Using a module

```hcl
module "web_server" {
  source = "./modules/ec2"

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  instance_name = "web-server-01"
}
```

---

## Terraform Commands Summary

```bash
terraform init          # Initialize directory
terraform fmt          # Format configuration files
terraform validate     # Validate configuration
terraform plan         # Preview changes
terraform apply        # Apply changes
terraform destroy      # Remove all resources
terraform show         # Show current state
terraform state list   # List resources in state
terraform state show   # Show specific resource
terraform output       # Show outputs
terraform workspace    # Manage workspaces
terraform import       # Import existing resources
```

---
