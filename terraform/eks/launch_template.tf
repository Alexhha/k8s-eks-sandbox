resource "aws_launch_template" "amd64" {
    name          = "amd64-default"
    image_id      = data.aws_ami.eks_node_group_image_amd64.id
    key_name      = var.remote_access_enabled ? aws_key_pair.ssh_public_key.key_name : null
    ebs_optimized = true

    vpc_security_group_ids = [
        aws_eks_cluster.k8s-cluster.vpc_config[0].cluster_security_group_id
    ]

    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_size = 20
            volume_type = "gp2"
        }
    }

    monitoring {
        enabled = false
    }

    user_data = base64encode(templatefile(
        "${path.root}/files/bootstrap.sh",
        {cluster_name = aws_eks_cluster.k8s-cluster.id}
    ))

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "eks-${var.k8s_version}-node-group-${var.eks_node_group_distro}_amd64"
        }
    }
}


resource "aws_launch_template" "arm64" {
    name          = "arm64-default"
    image_id      = data.aws_ami.eks_node_group_image_arm64.id
    key_name      = var.remote_access_enabled ? aws_key_pair.ssh_public_key.key_name : null
    ebs_optimized = true

    vpc_security_group_ids = [
        aws_eks_cluster.k8s-cluster.vpc_config[0].cluster_security_group_id
    ]

    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_size = 20
            volume_type = "gp2"
        }
    }

    monitoring {
        enabled = false
    }

    user_data = base64encode(templatefile(
        "${path.root}/files/bootstrap.sh",
        {cluster_name = aws_eks_cluster.k8s-cluster.id}
    ))

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "eks-${var.k8s_version}-node-group-${var.eks_node_group_distro}_arm64"
        }
    }
}
