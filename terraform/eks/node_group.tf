resource "aws_eks_node_group" "linux_amd64" {
    count           = var.amd64_enabled ? 1 : 0
    cluster_name    = aws_eks_cluster.k8s-cluster.id
    subnet_ids      = ["subnet-0e5b933658deb9bdd", "subnet-0375b5fa4575e0964"]
    node_role_arn   = aws_iam_role.eks-iam-nodegroup.arn
    node_group_name = "linux-amd64-${var.eks_node_group_distro}-${random_id.aws-prefix.hex}"
    capacity_type   = var.capacity_type
    instance_types  = ["t3.small", "t3.medium"]

    launch_template {
        name    = aws_launch_template.amd64.name
        version = aws_launch_template.amd64.latest_version
    }

    scaling_config {
        min_size     = var.node_count
        max_size     = var.node_count
        desired_size = var.node_count
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEC2ContainerRegistryReadOnly,
    ]
}


resource "aws_eks_node_group" "linux_arm64" {
    count           = var.arm64_enabled ? 1 : 0
    cluster_name    = aws_eks_cluster.k8s-cluster.id
    subnet_ids      = ["subnet-0e5b933658deb9bdd", "subnet-0375b5fa4575e0964"]
    node_role_arn   = aws_iam_role.eks-iam-nodegroup.arn
    node_group_name = "linux-arm64-${var.eks_node_group_distro}-${random_id.aws-prefix.hex}"
    capacity_type   = var.capacity_type
    instance_types  = ["t4g.small", "t4g.medium"]

    launch_template {
        name    = aws_launch_template.arm64.name
        version = aws_launch_template.arm64.latest_version
    }

    scaling_config {
        min_size     = var.node_count
        max_size     = var.node_count
        desired_size = var.node_count
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEC2ContainerRegistryReadOnly,
    ]
}


resource "aws_eks_node_group" "windows_amd64" {
    count           = var.win64_enabled ? 1 : 0
    cluster_name    = aws_eks_cluster.k8s-cluster.id
    subnet_ids      = ["subnet-0e5b933658deb9bdd", "subnet-0375b5fa4575e0964"]
    node_role_arn   = aws_iam_role.eks-iam-nodegroup.arn
    node_group_name = "windows-64-${random_id.aws-prefix.hex}"
    ami_type        = "WINDOWS_CORE_2019_x86_64"
    capacity_type   = var.capacity_type
    disk_size       = "50"
    instance_types  = ["t3.small", "t3.medium"]

    dynamic "remote_access" {
        for_each = var.remote_access_enabled ? {enabled=true} : {}
        content {
            ec2_ssh_key = aws_key_pair.ssh_public_key.key_name
        }
    }

    scaling_config {
        min_size     = var.node_count
        max_size     = var.node_count
        desired_size = var.node_count
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.eks-iam-nodegroup-AmazonEC2ContainerRegistryReadOnly,
    ]
}
