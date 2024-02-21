resource "aws_eks_addon" "ebs_csi_driver" {
    cluster_name = aws_eks_cluster.k8s-cluster.id
    addon_name   = "aws-ebs-csi-driver"
    depends_on   = [aws_eks_node_group.linux_amd64]
}


resource "aws_eks_addon" "vpc_cni" {
    cluster_name = aws_eks_cluster.k8s-cluster.id
    addon_name   = "vpc-cni"
    depends_on   = [aws_eks_node_group.linux_amd64]

    configuration_values = jsonencode({enableNetworkPolicy : "true"})
}


resource "aws_eks_addon" "coredns" {
    cluster_name = aws_eks_cluster.k8s-cluster.id
    addon_name   = "coredns"
    depends_on   = [aws_eks_node_group.linux_amd64]
}


resource "aws_eks_addon" "kube_proxy" {
    cluster_name = aws_eks_cluster.k8s-cluster.id
    addon_name   = "kube-proxy"
    depends_on   = [aws_eks_node_group.linux_amd64]
}
