# Python API + K8s stack

This project is intended to show a complete deployment process to a k8s cluster
## Development

Use docker compose to create a local development environment

```bash
make up -d
```

## Deploy cloud infrastructure
This step will  create all the infra required to run Python app, it includes:
* Kubernetes cluster using AWS EKS
* RDS Postgresql DB
* A new AWS VPC, subnets, security groups, etc.
* An AWS Secret inside of secrets manager storing DB credentials.

In order to create all infrastructure, you need to set up your default AWS credentials: follow this [guide](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)

```bash
cd infrastructure/base
terraform init
terraform plan
terraform apply
```
## Deploy a new version
In order to deploy a new version to the cluster, the first manual step is setup your kubeconfig for the cluster as a secret in Github, follow the next steps:

As requirements for the next steps, you need to install and set up authentication for: [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [Github CLI](https://github.com/cli/cli#installation).

```bash
# after cluster creation finish
aws eks update-kubeconfig --name demo --kubeconfig ~/.kube/config.bk --region sa-east-1

#Encode kube config to base64 and set it on GH secrets
cat ~/.kube/config.bk |base64 > ~/.kube/configb64 && gh secret set KUBE_CONFIG_DATA < ~/.kube/configb64

```
The last set up is just the first time, to deploy a new version of Python app, just push a commit to main branch
```bash
git commit -m "<commit message>"
git commit push origin main
```
The main CI/CD pipeline is defined in: `./github/workflows/ci.yaml`

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.