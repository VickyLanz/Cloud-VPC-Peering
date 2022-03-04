module "vpc" {
  source ="../module/vpc/"
  name   = "vpc-1"
  project_id = var.mproject_id
  subnets = [{
    ip_cidr_range="10.0.1.0/24"
    name="vpc-1-us-subnet"
    region="us-central1"
    secondary_ip_range=null
  }]
}
module "firewall_rules_1" {
  depends_on = [module.vpc]
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.mproject_id
  network_name = module.vpc.name

  rules = [{
    name                    = "allow-ssh-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "allow-all-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["0-65535"]
    },{
      protocol="udp"
      ports=["0-65535"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "allow-all-rdp-icmp"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    },{
      protocol="icmp"
      ports=null
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}
module "vpc-2" {
  source ="../module/vpc/"
  depends_on = [module.vpc]
  name   = "vpc-2"
  project_id = var.mproject_id
  subnets = [{
    ip_cidr_range="10.0.2.0/24"
    name="vpc-2-eu-subnet"
    region="europe-west1"
    secondary_ip_range=null
  }]
  peering_config = {
    peer_vpc_self_link=module.vpc.self_link
    export_routes=false
    import_routes=true
  }
}
module "firewall_rules_2" {
  depends_on = [module.vpc-2]
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.mproject_id
  network_name = module.vpc-2.name

  rules = [{
    name                    = "allow-ssh-ingress-2"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "allow-all-ingress-2"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["0-65535"]
    },{
      protocol="udp"
      ports=["0-65535"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "allow-all-rdp-icmp-2"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["3389"]
    },{
      protocol="icmp"
      ports=null
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}


module "vm" {
  source = "../module/vm/"
  depends_on = [module.vpc]
  name   = "vpc-1-vm"
  network_interfaces = [{
    network=module.vpc.self_link
    subnetwork=module.vpc.subnet_self_links["us-central1/vpc-1-us-subnet"]
    nat=true
    addresses=null
  }
  ]
  project_id = var.mproject_id
  zone = var.mzone
}
module "vm-2" {
  source = "../module/vm/"
  depends_on = [module.vpc-2]
  name   = "vpc-2-vm"
  network_interfaces = [{
    network=module.vpc-2.self_link
    subnetwork=module.vpc-2.subnet_self_links["europe-west1/vpc-2-eu-subnet"]
    nat=true
    addresses=null
  }
  ]
  project_id = var.mproject_id
  zone = var.mzone2

}
