variable "region" {
    type    = string
    default = "eu-central-1"
}


variable "k8s_version" {
    type    = string
    default = "1.28"
}


variable "node_count" {
    type    = string
    default = "1"
}


variable "capacity_type" {
    type    = string
    default = "SPOT"
}


variable "remote_access_enabled" {
    type = bool
    default = false
}


variable "amd64_enabled" {
    type    = bool
    default = true
}


variable "arm64_enabled" {
    type    = bool
    default = false
}


variable "win64_enabled" {
    type    = bool
    default = false
}


variable "disk_size" {
    type    = string
    default = "20"
}


variable "instance_type" {
    type    = list
    default = ["t3.small", "t3.medium", "t4g.small", "t4g.medium"]
}


variable "whitelist_ips" {
    type    = list
    default = []
}


// [al2|al2023|ubuntu]
variable "eks_node_group_distro" {
    type    = string
    default = "al2"
}

variable "ami_distro_owner" {
    type    = map
    default = {
        "al2"    = "602401143452"
        "al2023" = "602401143452"
        "ubuntu" = "099720109477"
    }
}
