# defining the provider for Google Cloud Platform (GCP)
provider "google" {
  credentials = "new_keys.json"  # path to GCP service account key file
  project     = "psychic-raceway-415521"  # GCP project ID
  region      = "us-central1"  # default region of GCP instances
}

# defining the provider for AWS
provider "aws" {
  region = "us-east-2"  # Default region of AWS instances
}

# random_id resource to generate unique identifiers for each instance
resource "random_id" "node_id" {
  count      = 10
  byte_length = 4
}

# defining the Google Compute Engine instances
resource "google_compute_instance" "gcp_instance" {
  count        = 5
  name         = "node-${random_id.node_id[count.index].hex}"  # generates a unique name for each instance
  machine_type = "n1-standard-1"
  zone         = random_string.region_zones_gcp.*.result[count.index]  # randomly choose a zone for each instance
}

# defining the AWS instances
resource "aws_instance" "aws_instance" {
  count         = 5
  ami           = "ami-02ca28e7c7b8f8be1"  # specify AMI ID for AWS linux instances
  instance_type = "t2.micro"
  availability_zone = random_string.region_zones_aws.*.result[count.index]  # randomly choose an availability zone for each instance

  # right now just using default security group
}

# defining random strings for regions and zones for Google Cloud Platform (GCP)
resource "random_string" "region_zones_gcp" {
  count    = 5
  length   = 1
  special  = false
  upper    = false
  number   = false
  min_lower = 0
  max_lower = length("us-central1")
  override_special = "_"
  override_upper = "_"
  override_number = "_"
  keepers = {
    region_index = random(length(local.regions_gcp))
    zone_index   = random(length(local.zones_gcp[local.regions_gcp[region_index]]))
  }
  generate {
    result = "${local.regions_gcp[region_index]}/${local.zones_gcp[local.regions_gcp[region_index]][zone_index]}"
  }
}

# defining random strings for regions and zones for AWS
resource "random_string" "region_zones_aws" {
  count    = 5
  length   = 1
  special  = false
  upper    = false
  number   = false
  min_lower = 0
  max_lower = length(local.zones_aws[random(length(local.regions_aws))])
  override_special = "_"
  override_upper = "_"
  override_number = "_"
  keepers = {
    region_index = random(length(local.regions_aws))
    zone_index   = random(length(local.zones_aws[local.regions_aws[region_index]]))
  }
  generate {
    result = "${local.regions_aws[region_index]}/${local.zones_aws[local.regions_aws[region_index]][zone_index]}"
  }
}

# defining local variables for regions and zones
locals {
  regions_gcp = ["us-central1", "us-east1", "europe-west2", "asia-east1", "australia-southeast1"]
  zones_gcp   = {
    us-central1           = ["us-central1-a", "us-central1-b", "us-central1-c"],
    us-east1              = ["us-east1-b", "us-east1-c", "us-east1-d"],
    europe-west2          = ["europe-west2-a", "europe-west2-b", "europe-west2-c"],
    asia-east1            = ["asia-east1-a", "asia-east1-b", "asia-east1-c"],
    australia-southeast1  = ["australia-southeast1-a", "australia-southeast1-b", "australia-southeast1-c"]
  }
  
  regions_aws = ["us-west-2", "us-east-1", "eu-west-1", "ap-southeast-1", "ap-northeast-1"]
  zones_aws   = {
    "us-west-2"          = ["us-west-2a", "us-west-2b", "us-west-2c"],
    "us-east-1"          = ["us-east-1a", "us-east-1b", "us-east-1c"],
    "eu-west-1"          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"],
    "ap-southeast-1"     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"],
    "ap-northeast-1"     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  }
}

# output of the details of the provisioned nodes
output "node_details" {
  value = {
    # output details of Google Compute Engine instances
    "gcp_instances" : [
      for idx, instance in google_compute_instance.gcp_instance : {
        node_id       = instance.name
        cloud_provider = "GCP"
        region        = split("/", instance.zone)[0]
        zone          = split("/", instance.zone)[1]
      }
    ],
    # output details of AWS instances
    "aws_instances" : [
      for idx, instance in aws_instance.aws_instance : {
        node_id       = instance.id
        cloud_provider = "AWS"
        region        = split("/", instance.availability_zone)[0]
        zone          = split("/", instance.availability_zone)[1]
      }
    ]
  }
}
