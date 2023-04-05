# keycloak-aws
Deployment of keycloak service using AWS Elastic Container Service  
IaC achieved by using Terraform

##AWS access and IAM configuration

To keep Prod and Staging separated, 2 AWS distinct acocunts will be used. The management of these accounts is done by using AWS Organizations where I created the following structure: 

Root(account)   
├── Infrastructure OU  
├── Workloads OU   
│     ├── Production  
│     ├── Staging  

Then, using IAM Identity Center I created 2 accounts: "devops" and "developer" and applied the following account policies:
- AdministratorAccess for the devops user and ReadOnly for the developer on the Production account
- AdministratorAccess to the developer user and ReadOnly to the devops on the Staging account

On my computer I configured awscli (following the documentation) and then using ```aws configure sso``` I created 2 different profiles inside aws/config, as seen below)

```
cat ~/.aws/config
[default]
[profile my-dev-profile]
sso_session = developer-staging
sso_account_id = 555555555
sso_role_name = AdministratorAccess
region = us-east-2
[sso-session developer-staging]
sso_start_url = https://XXX.awsapps.com/start
sso_region = us-east-2
sso_registration_scopes = sso:account:access
[profile my-prod-profile]
sso_session = devops-prod
sso_account_id = 777777777
sso_role_name = AdministratorAccess
region = us-east-2
[sso-session devops-prod]
sso_start_url = https://XXX.awsapps.com/start
sso_region = us-east-2
sso_registration_scopes = sso:account:access
```

This configuration simplifies the interaction with the AWS CLI when using a multi-account setup and facilitates the user authentication without using passwords or access key(that could be exposed or commited to git by mistake). 

To login just lunch:
```
aws sso login --sso-session developer-staging
or
aws sso login --sso-session devops-prod
```
