data "aws_vpc" "default" {
    default = true
}


data "aws_subnets" "default" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}


data "aws_instances" "node_group" {
    filter {
        name   = "tag:eks:cluster-name"
        values = [aws_eks_cluster.k8s-cluster.id]
    }

    instance_state_names = ["pending", "running"]
}


data "aws_eks_cluster_auth" "k8s-auth" {
    name = aws_eks_cluster.k8s-cluster.id
}


data "aws_ami" "eks_node_group_image_amd64" {
    most_recent = true
    owners      = [var.ami_distro_owner[var.eks_node_group_distro]]

    filter {
        name   = "name"
        values = [local.ami_distro_filter["amd64"][var.eks_node_group_distro]]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
}


data "aws_ami" "eks_node_group_image_arm64" {
    most_recent = true
    owners      = [var.ami_distro_owner[var.eks_node_group_distro]]

    filter {
        name   = "name"
        values = [local.ami_distro_filter["arm64"][var.eks_node_group_distro]]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "architecture"
        values = ["arm64"]
    }
}
