# defining the provider for Google Cloud Platform (GCP)
provider "google" {
  credentials = file("/home/sathya/supra_oracles/credentials.json")  # path to GCP service account key file
  project     = "task2-tf-921"  # GCP project ID
  region      = "us-central1"  # default region of GCP instances
}

# defining the provider for AWS
provider "aws" {
  region = "us-west-2"  # Default region of AWS instances
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
  zone         = random_region_zone.google[count.index].result  # randomly choose a zone for each instance

}

# defining the AWS instances
resource "aws_instance" "aws_instance" {
  count         = 5
  ami           = "ami-12345678"  # specify AMI ID for AWS linux instances
  instance_type = "t2.micro"
  availability_zone = random_region_zone.aws[count.index].result  # randomly choose an availability zone for each instance

  # right now just using default security group
}

# defining resource to generate random regions and zones for Google Cloud Platform (GCP)
resource "random_region_zone" "google" {
  count  = 5
  result = "${random_region_zone.generate_random_region_zone("gcp")}"
}

# defining resource to generate random regions and zones for AWS
resource "random_region_zone" "aws" {
  count  = 5
  result = "${random_region_zone.generate_random_region_zone("aws")}"
}

# defining local variables for regions and zones
locals {
  regions_gcp = ["us-central1", "us-east1", "europe-west2", "asia-east1", "australia-southeast1"]
  zones_gcp   = {
    us-central1 = ["us-central1-a", "us-central1-b", "us-central1-c"],
    us-east1    = ["us-east1-b", "us-east1-c", "us-east1-d"],
    europe-west2 = ["europe-west2-a", "europe-west2-b", "europe-west2-c"],
    asia-east1   = ["asia-east1-a", "asia-east1-b", "asia-east1-c"],
    australia-southeast1 = ["australia-southeast1-a", "australia-southeast1-b", "australia-southeast1-c"]
  }
  regions_aws = ["us-west-2", "us-east-1", "eu-west-1", "ap-southeast-1", "ap-northeast-1"]
  zones_aws   = {
    "us-west-2"          = ["us-west-2a", "us-west-2b", "us-west-2c"],
    "us-east-1"          = ["us-east-1a", "us-east-1b", "us-east-1c"],
    "eu-west-1"          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"],
    "ap-southeast-1"     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"],
    "ap-northeast-1"     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  }

  # function to generate a random region and zone
  generate_random_region_zone = function(provider) {
    if provider == "gcp" {
      random_region_index = random(length(local.regions_gcp))
      region = local.regions_gcp[random_region_index]
      zones = local.zones_gcp[region]
      random_zone_index = random(length(zones))
      zone = zones[random_zone_index]
    } else {
      random_region_index = random(length(local.regions_aws))
      region = local.regions_aws[random_region_index]
      zones = local.zones_aws[region]
      random_zone_index = random(length(zones))
      zone = zones[random_zone_index]
    }
    "${region}/${zone}"
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
