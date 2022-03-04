terraform {
  backend "gcs" {
    prefix = "triple-baton-337806/vpc-peering"
    bucket = "triple-baton-337806"
  }
}