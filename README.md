# GitHub AWS Automated Webserver Pipeline Template
This repository contains an AWS auto-deploy workflow that can be triggered on specific events. The workflow is designed to deploy code, run tests, provision infrastructure using Terraform, and configure the deployed instance using Ansible. It also performs tasks such as copying files to an S3 bucket, waiting for instance initialization, and posting a comment with the IP of the webserver:
- Basic ec2 webserver pipeline deployments/configuration fully automated with Terraform, AWS, GitHub and Ansible.
- Meant to be expanded uplon via use of different Terraform states infrastructures.
- Manual pipeline triggers for automated QA tests to be run on main branches only.
- Automated resource management for cost efficiency and auto-state refresh to prevent API drifting.

## Encrypted Repository Secrets
The workflow requires Administrator credentials with programmatic access to AWS API to be stored as an encrypted credentials in the repository variable settings:
- `AWS_ACCESS_KEY_ID` - programmatic AWS API access required for Terraform cloud resource automation
- `AWS_SECRET_ACCESS_KEY` - programmatic AWS API access required for Terraform cloud resource automation
- `TOKEN_COMMENT` - GitHub token for comment variable automation i.e. IP of test server
- `AWS_PRIVATE_KEY` - AWS Private RSA Keypair `pem` file used for SSH access for Ansible

## Workflow Triggers
The workflow is triggered by the following events:
- Pull requests on the main branch
- Scheduled execution at midnight

## Manual Triggers
You can trigger the deploy or destroy jobs manually in the main branch only.
Simply go to the actions sectioni of that repos main branch and you will see "work dispatch" and should allow you to manually run any job.

## Environment Variables
The following environment variables are used in the workflow:
- `AWS_REGION`: The AWS region for deployment
- `BUCKET_SRC`: The source code S3 bucket

## Workflow Steps
The workflow consists of two main jobs: deploy and destroy.

### Deploy Job
The deploy job is responsible for deploying the code and provisioning the infrastructure. It performs the following steps:
1. Checks out the code from the repository.
2. Configures AWS credentials.
3. Installs dependencies and runs tests.
4. Sets up SSH for the instance.
5. Initializes Terraform and applies the infrastructure.
6. Extracts Terraform output and creates an Ansible inventory file.
7. Copies files to an S3 bucket.
8. Installs Ansible and waits for instance initialization.
9. Adds the new EC2 instance to known hosts.
10. Runs the Ansible playbook.
11. Posts a comment with the DNS IP URL.

### Destroy Job
The destroy job is responsible for destroying the provisioned infrastructure. It performs the following steps:
1. Checks out the code from the repository.
2. Configures AWS credentials.
3. Initializes Terraform and destroys the infrastructure.

## Setup
Setup your cloud infrastructure state with designating your Terraform keypath via S3 backend:
- Go to `main.tf` in `/yourpipelinename/terraform/main.tf`
- Edit `bucket` value with your AWS S3 bucket for state files
- Edit `key` value of `backend s3` resource to a path of your choice i.e. `bucketname/terraform.tfstate`
```
terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket      = "tf-dev-remote-state-github-piplines"
    key         = "auto-provision-pr-pipe/terraform.tfstate"
    region      = "us-west-2"
    encrypt     = true
  }
}
```

## Usage
After you setup your state file infrastructure key path in s3 and have your Admin configure your secrets for your new cloud enironment:
- Trigger a new cloud enironment to be created, simply clone this repo and create a new test branch
- Have a DevOps Engineer configure new environment for your specific tests so workflow can be triggered on source code
- Commit changes to your test branch, `git push` and set remote repository origin since its a fresh branch
- Open a Pull Request in GitHub with at least 1 reviewer, which starts the workflow `deploy` job and will begin the automated tests
    - These tests can be later triggered again manually on the Main branch only for the time being
- You can view the test cloud environments IP address via the open pull requests section in GitHub repo to view your website
- After tests have passed and website changes meet your needs, merge if no conflicts
- Once on main branch if you would like to view the cloud enironment again, you can manually trigger the `deploy` job which will:
    - run automated tests again..
    - allow you to view the website with a temporary IP
    - after 24hrs the env will be destroyed but can always be redeployed
