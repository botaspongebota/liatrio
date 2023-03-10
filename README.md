### Bota Tolepbergen for Liatrio 
![BotaSpongeBota](https://media.giphy.com/media/SKGo6OYe24EBG/giphy.gif)

Technologies Used:

**Terraform**: a tool for building, changing, and versioning infrastructure safely and efficiently.

**Kubernetes**: a portable, extensible, open-source platform for managing containerized workloads and services.

**Docker**: a platform for developing, shipping, and running applications in containers.

**AWS** (Amazon Web Services): a cloud computing platform that provides a wide range of services and tools for building and deploying cloud-based applications and services.

**AWS CLI**: a command-line interface tool for interacting with AWS services and resources from the command line.

**kubectl**: a command-line tool for deploying and managing applications on Kubernetes clusters.
Additionally, the configuration files include AWS resources such as Elastic Container Registry (ECR), Elastic Kubernetes Service (EKS), IAM roles and policies, and security groups.


The prerequisites for using the README file and the technologies mentioned are:

**A valid AWS account**

**AWS CLI installed and configured with your AWS credentials**

**Terraform installed**

**kubectl installed**

**docker**

Single command to launch the environment and deploy the application
```shell
make deploy
```

Single command to destroy the environment with all dependancies 
```shell
make destroy
```

This README file provides an overview of the various files in a Terraform configuration that deploys an example application to a Kubernetes cluster on AWS using Docker containers. The file describes the resources created in each file, including the AWS ECR container registry, the EKS cluster on AWS, an EKS node group, and the VPC with public and private subnets, security groups, and gateways. To use this configuration file, you need to have a valid AWS account, the AWS CLI, Terraform, and kubectl installed. You can customize the Terraform and Makefile variables and modify the resources as needed to fit your specific use case.

To use this configuration file, you would need to have a valid AWS account, have installed the AWS CLI (set up your AWS credentials in your environment), Terraform, and have kubectl installed. You would also can customize the Terraform and Makefile variables and modify the resources as needed to fit your specific use case. 

--------------------
![tech](https://media.giphy.com/media/lS70Xe4FNYGayQvSp9/giphy.gif)


Example App in Docker Image
This Docker image runs a web application that returns a JSON message and a timestamp. The image is based on the python:3.9-slim-buster image and installs the Flask package and copies the app.py file to the /app directory in the container.

--------------------
**deploy.yaml**

This Kubernetes deployment and service run a single instance of the Example App container image. The deployment and service are defined in separate manifests and are designed to run on a Kubernetes cluster.

The Example App container image stored in AWS ECR container registry. ClusterIP service exposes the Example App deployment on port 80. Load Balancer Service make accessible our app from the Internet.

--------------------
**ecr.tf** 

AWS ECR Repository
This Terraform resource creates an Amazon Elastic Container Registry (ECR) repository named bota. The repository allows mutable image tags and enables image scanning on push.

Outputs
The arn output returns the Amazon Resource Name (ARN) of the ECR repository.


----------------------------
**eks-cluster.tf**

This Terraform code creates an EKS cluster on AWS.

aws_iam_role
This resource creates an IAM role that the EKS cluster assumes.


```shell
aws_iam_role_policy_attachment
```
This resource attaches the AmazonEKSClusterPolicy policy to the IAM role created by the *aws_iam_role* resource.

The depends_on attribute specifies that the *aws_iam_role_policy_attachment* resource named *cluster_AmazonEKSClusterPolicy* must be created before the aws_eks_cluster resource is created.

```shell
aws_security_group
```
This resource creates a security group for the EKS cluster.

```shell
aws_security_group_rule
```
(cluster_inbound) Port 443
This resource creates an inbound security group rule that allows worker nodes to communicate with the cluster API Server.

```shell
aws_security_group_rule
```
(cluster_outbound) Port 1024
This resource creates an outbound security group rule that allows the cluster API Server to communicate with worker nodes.

Outputs
This code exports the following outputs:

```shell
aws_eks_cluster_endpoint
```
The endpoint URL for the EKS cluster API server.
```shell
aws_eks_cluster_name
```
The name of the EKS cluster.
```shell
aws_eks_cluster_security_group_id
```
The ID of the security group for the EKS cluster.


----------------------
**node-groups.tf**

This is a Terraform configuration file for creating an EKS (Elastic Kubernetes Service) node group in AWS (Amazon Web Services). It includes the following resources:

```shell
aws_eks_node_group
```
This resource creates a node group in the specified EKS cluster with the given parameters, including the desired capacity, instance types, and disk size.
```shell
aws_iam_role
```
This resource creates an IAM (Identity and Access Management) role for the EKS node group to assume.
```shell
aws_iam_role_policy_attachment
```
These resources attach policies to the IAM role for the EKS node group, granting the necessary permissions to interact with the EKS cluster and other AWS services.
```shell
aws_security_group
```
This resource creates a security group for the EKS nodes to control inbound and outbound traffic.
```shell
aws_security_group_rule
```
These resources define the rules for the EKS node security group to allow communication between nodes and with the EKS control plane (Master Node).
The configuration file uses variables defined elsewhere to specify the EKS cluster name, project name, VPC ID, and tags for the resources. The file also includes a depends_on clause to ensure that the IAM policies are attached before the node group is created.

---------------------
**outputs.tf**

This is a Terraform configuration file that creates outputs for an EKS (Elastic Kubernetes Service) cluster created in AWS (Amazon Web Services). The outputs include the following information:

```shell
cluster_name
```
This output displays the name of the EKS cluster that was created using the Terraform configuration file. The value is obtained from the "aws_eks_cluster" resource using the ".name" attribute.

```shell
cluster_endpoint
```
This output displays the endpoint URL for the EKS cluster. The value is obtained from the "aws_eks_cluster" resource using the ".endpoint" attribute.

```
shell
cluster_ca_certificate
```
This output displays the base64 encoded certificate authority (CA) data for the EKS cluster. This data is required to authenticate and communicate with the EKS cluster. The value is obtained from the "aws_eks_cluster" resource using the ".certificate_authority[0].data" attribute.

----------------------
**providers.tf**

This is the Terraform configuration block at the beginning of a Terraform configuration file. It specifies the minimum version of Terraform required to apply the configuration, and the required version of the AWS provider.

----------------------
**terraform.tfvars**

```shell
region
```
This sets the AWS region to "us-east-1".
```shell
availability_zones_count
```
This sets the number of availability zones to 2.
```shell
project
```
This sets the name of the project to "Liatrio-Bota".
```shell
vpc_cidr
```
This sets the CIDR block for the VPC to "10.0.0.0/16".
```shell
subnet_cidr_bits
```
This sets the number of bits to use for the subnet CIDR blocks to 8.

----------------------
**vpc.tf**

This Terraform code provisions a Virtual Private Cloud (VPC) with public and private subnets, an Internet Gateway (IGW), a NAT Gateway, and two security groups: one for the public subnet and one for the data plane (Worker Node).

The *aws_vpc* resource creates a new VPC with a specified CIDR block and DNS support enabled. The VPC is also tagged with a Name tag and a Kubernetes cluster tag.

The *aws_subnet* resource is used to create both public and private subnets. The public subnet has a *map_public_ip_on_launch* parameter set to true, which enables instances launched in this subnet to receive a public IP address automatically. Both public and private subnets are tagged with a Name tag and a Kubernetes cluster tag.

The *aws_internet_gateway* resource creates an Internet Gateway that is attached to the VPC created earlier. The gateway is tagged with a Name tag.

The *aws_route_table* resource creates a main route table for the VPC and adds a route to the Internet Gateway. The route table is tagged with a Name tag.

The *aws_route_table_association* resource associates the public subnet with the main route table.

The *aws_eip* resource creates an Elastic IP (EIP) that is used by the NAT Gateway. The EIP is tagged with a Name tag.

The *aws_nat_gateway* resource creates a NAT Gateway that is attached to the public subnet and uses the EIP created earlier. The NAT Gateway is tagged with a Name tag.

The *aws_route* resource adds a route to the main route table that points to the NAT Gateway.

The *aws_security_group* resource is used to create two security groups: one for the public subnet and one for the data plane. The security groups are tagged with a Name tag.

The *aws_security_group_rule* resources are used to define the inbound and outbound traffic rules for both security groups.

Note: This code assumes that var.project, var.availability_zones_count, var.vpc_cidr, and var.subnet_cidr_bits have been defined in the terraform.tfvars.


--------------------
**Makefile**

This is a Makefile with commands to create and destroy AWS resources, build and push a Docker image, update the kubeconfig file, and deploy the application to a Kubernetes cluster.

The variables used in this Makefile are:

```shell
$(account)
```
The AWS account ID.
```shell
$(region)
```
The AWS region to use.
```shell
$(rep_name)
```
The name of the ECR repository to use.
```shell
$(lb_url)
```
The URL of the load balancer used by the Kubernetes service.
The commands in this Makefile are:

```shell
vpc-eks-init-plan-apply
```
Creates the VPC and EKS cluster using Terraform.
```shell
build
```
Builds the Docker image.
```shell
login
```
Logs in to the ECR repository.
```shell
push
```
Pushes the Docker image to the ECR repository.
```shell
update-kubeconfig
```
Updates the kubeconfig file with the EKS cluster information.
```shell
deploy
```
Deploys the application to the Kubernetes cluster.
```shell
destroy-kubernetes-objects
```
Deletes the Kubernetes objects created by the deploy command.
```shell
destroy-aws-resources
```
Destroys the AWS resources created by the vpc-eks-init-plan-apply command.
Note: 

This Makefile assumes that the AWS CLI and kubectl are installed and configured with the appropriate credentials.



---------------------

Useful Links:

Terraform documentation: https://www.terraform.io/docs/index.html

Kubernetes documentation: https://kubernetes.io/docs/home/

Docker documentation: https://docs.docker.com/

AWS documentation: https://aws.amazon.com/documentation/

AWS CLI documentation: https://docs.aws.amazon.com/cli/index.html

kubectl documentation: https://kubernetes.io/docs/tasks/tools/

Elastic Container Registry (ECR) documentation: https://aws.amazon.com/ecr/

Elastic Kubernetes Service (EKS) documentation: https://aws.amazon.com/eks/

IAM roles and policies documentation: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html

Security groups documentation: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html



Author
Bota Tolepbergen


![BotaSpongeBota](https://media.giphy.com/media/3oEdva9BUHPIs2SkGk/giphy.gif)