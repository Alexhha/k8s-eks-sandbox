data "aws_vpc" "default-vpc" {
    default = true
}


data "aws_subnets" "default-subnet" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.default-vpc.id]
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


data "template_file" "kube_config" {
    depends_on = [aws_eks_cluster.k8s-cluster]
    template = templatefile(
        "${path.module}/templates/kube.config",
        {
            eks_name     = "${aws_eks_cluster.k8s-cluster.id}"
            eks_endpoint = "${aws_eks_cluster.k8s-cluster.endpoint}"
            eks_root_ca  = "${aws_eks_cluster.k8s-cluster.certificate_authority.0.data}"
            eks_region   = "${var.region}"
        }
    )
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
