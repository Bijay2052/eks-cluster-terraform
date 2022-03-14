# Terraform Kubernetes modules

## Table of Contents

* [Overview](#overview)
* [Variants during deployment of infrastructure](variants-during-deployment-of-infrastructure)
* [Development Setup](#development-setup)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Infrastructure Deployment](#infrastructure-deployment)
* [Infrastructure Deletion](#infrastructure-deletion)
* [Dockerizing App](#dockerizing-app)
* [Deploying App using Helm](#deploying-app)

## Overview

This project contains the terraform scripts to deploy a complete EKS cluster inside terraform folder, Helm3 charts for deployment of a simple nginx container inside helm directory and inside app directory there are Docker file and config files which is used to create docker image.

Eks Kubernetes's infrastructure is provisioned using `Terraform` which provides us with declarative interface for managing cloud resources lifecycle. The main principle behind managing infrastructure as a code is `Idempotence`, which ensures deployment is consistent as a function of time and change. For instance, `resource` in the context of terraform could be ec2-compute in AWS cloud whose declarative configuration could look something like below:

```terraform
resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}
```


Above resource declaration is written in language known as `HCL` which stands for Hashicorp Configuration Language developed by Hashicorp whose semantics is equivalent to JSON configuration. Terraform with the given resource definition is then responsible for managing lifecycle which includes:

| Phase    | Equivalent `Terraform` Command |
|----------|------------------------------|
| Creation | `terraform apply`              |
|  Update  | `terraform apply`              |
|  Deletion  | `terraform destroy`            |

There are following top level resource definition within this projects infrastructure. They are as follows:
- Amazon Elastic Kubernetes Service Master
- Amazon Elastic Kubernetes Service Workers
- VPC
- Routing tables
- Subnets
- SGs
- Amazon Elastic Container Registry
- AWS ingress controller
- Bastion Hosts
- AutoScaling Groups

## Variants during deployment of infrastructure

### Terraform state file

Any deplyment of actual aws resources through terraform results in a state file which represents the current state of deployed resources within AWS. This state file has an extension of `.tfstate` which is maintained at terraform cloud. Way of managing terraform state files in some remote location during terraform deployment/apply is called `remote deployment strategy`. The reason behing keeping the statefile in central place such as terraform cloud have following advantages:

1. We have single source of truth for any changes into the infrastructure.
2. Two concurrent modification of resources is prohibited as any arbitary deployment needs to acquire lock for making changes to resources which results in another deployment to fail.
3. We can prevent arbitary deployment by manually locking statefile.
4. We can provision access control around the statefile and only allow trusted individual to actually make changes to infrastructure (using workspace)

### Workspace

In terraform, any terraform stateful shoud reside within workspace. We can think of workspace as a way of namespacing the statefile. This allows administrator to provision access control by only allowing `release team` to make changes to terraform deployment. For instance, we could isolate environment and stages by workspace and assign users to dedicated developers/devops.

### Locks in terraform

During planning and applying terraform code, terraform, by default, generated statefile in machine where `terraform plan` and `terraform apply` was executed. This is horrible practise as this might lead to state file maintained within local machine and not in central location. Also, multiple `terraform apply` can be initiated at the same time which would in programming term result in `datarace`. This is something we want to avoid. Hence, we need to maintain a consistent lock during `terraform apply`. This can achieved by using combination of cloud storage and database(dyanamo DB). However, this we can use terraform cloud to simply use their locking mechanism and don't need to maintain our own setup for locks.

### Note during deletion of infrastructure

During deletion using `terraform destroy`, terraform would delete all of the resources except `Dangling resources`. Dangling resources are those resources whose lifecyle is not managed by terraform and instead these are created indirectly by managed resources such as EKS(Elastic kubernetes Service). For instance, EKS would deploy ALB for ingress controller to route incoming traffic to EKS's gateway/ http reverse proxy.

Also, in some cases Persistent Volumes which are dyanamically mouted to Ec2 worker nodes via Persistent Volume Claims(PVCs) would faile to unmount and destroy when we destroy  EKS master and EKS worker nodes. In this particular scenario, we need to manually delete the EBS volumes created as the result of PVCs.

Similarly, terraform fails to delete any object storage(s3 bucket) if we have a contents inside that storage object. Hence, we need to make sure we delete all the contents of all versions within object storage before calling `terraform destroy`.

Therefore, steps to destroy infrastructure are as below:

1. Delete all the deployment inside EKS cluster via greping namespaces.
```sh
ls | grep dev- | awk '{print $1}' | xargs kubectl delete
```
This would all the deployments whose namespace is prefixed by `dev-`. This would result in deletion of actual aws resources if any deployment happen to manage PVs and ingress controller.
2. Delete contents of all the object storage.
3. Finally, run `terraform destroy`.

> Note, sometime terraform destroy would fail. World is not perfect and will never be. In this case, we need to go beyond terrraform destroy and have to manually fix the statefile using `terraform state` command provided by terraform. This command is advanced and should only be used if something went down the graveyard. This command will let us remove, list and change state manually.

> Again, Don't use it. There must be a way.

## Development Setup

### Prerequisites

* [Docker](https://docs.docker.com/install/)
* [Git](https://git-scm.com/downloads)
* [Terraform](https://www.terraform.io/downloads)
* [AWS cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Helm](https://helm.sh/docs/intro/install/)
### Installation

##### 1. Clone the repository

```sh
git clone <git url of this repo>
```

##### 2. Create `.terraformrc` file inside your root directory with the following content. Note: Get the required token from [terraform cloud](https://www.terraform.io/).

```
credentials "app.terraform.io" {
  token = "*********************"
}
```


##### 3. Create terraform variable file (terraform.tfvars) based on template file `terraform/terraform_tfvars.example`
   * Create a terraform variable file called `terraform.tfvars` inside `terraform` directory as `terraform/terraform.tfvars`. From root directory, run the below shell command.
   ```sh
   cd terraform/
   cp terraform_tfvars.example terraform.tfvars
   ```

##### 4. Create new workspace or use the existing workspace for terraform state management

>We isolate the terraform environment using the `workspace` so it is important that you create a new workspace when you are working on new feature. This prevents messing up existing environement i.e prod, dev, qa.

##### To create new workspace

Set a env variable in Makefile.override.dev `TF_WORKSPACE` as `TF_WORKSPACE ?= new-workspace`.
Run the following shell command.
```sh
terraform workspace new <example_workspace>
```
>Note: Set the execution mode from `Remote` to `Local` in [terraform cloud](https://app.terraform.io). This option should be located in `settings > General`. This needs to be done as we are using local machine to drive changes to terraform and we need to explictly set the execution mode to `Local` as it will pick up the environment variables from our local machine in order to run terraform commands.

##### To use existing workspace

Get the list of workspace by running following shell command.
```sh
terraform workspace list
terraform workspace select <workspace>
```

##### 5. Initialize the project
This initialization would install all the necessary plugins and download terraform modules required by the project.
```sh
terraform init
```

## Infrastructure Deployment
Steps that strictly needs to be accomplished for deployment:

#### 1. Output terraform plan
```sh
terraform plan
```

#### 2. Apply terraform plan
This will deploy the changes to aws and infrastructure will be created

```sh
terraform apply
```

## Infrastructure Deletion
#### 5. Destroy the resources provisioned by terraform

```sh
terraform destroy
```

## Dockerizing App
To dockerize the app go to app directory and run  following commands
```sh
docker build -t <image_name> .
```
After the app is docerized then we need to push the app to ECR. To push the image to ECR follow the following docs:
https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html

## Deploying App using Helm

After the docker image is pushed to ECR, we need to change the image name in the helm variables inside Values.yaml.
In values.yaml under containers tag, change the key with image tag and put the url of the ECR repo with the image tag.
For eg: <aws_account_id>.dkr.ecr.region.amazonaws.com/<my-repository:tag>
Then change the other variables in values.yaml as your wish and to deploy the app to EKS follow the steps:
Note: Follow the follwing stpes from project root directory.

```sh
helm install helm/nginx-deployment
```
Check the deployment status and after the deployment is successfull run the following command to get the ingress url:

```sh
kubectl get ingress/<ingress-name> -n <namespace> -o jsonpath='(.status.loadbalancer.ingress[0].hostname)' 
```
It will output the loadbalancer endpoint to access the application. Verify it through the browser.