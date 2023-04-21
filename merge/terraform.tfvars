aws_region        = "us-east-2"
cidr              = "10.0.0.0/16"

# these are zones and subnets examples
availability_zones = ["us-east-2a", "us-east-2b"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]

# these are used for tags
app_name        = "keycloak"
app_environment = "staging"
