output "a0" {
    value = "-----------------------------------------------------------------"
}

output "eks_cluster_arn" {
    value = aws_eks_cluster.k8s-cluster.arn
}

output "eks_cluster_endpoint" {
    value = aws_eks_cluster.k8s-cluster.endpoint
}

output "eks_cluster_id" {
    value = aws_eks_cluster.k8s-cluster.id
}

output "f0" {
    value = "-----------------------------------------------------------------"
}

output "node_group_id_amd64" {
    value = try(aws_eks_node_group.linux_amd64[0].id, "N/A")
}

output "node_group_id_arm64" {
    value = try(aws_eks_node_group.linux_arm64[0].id, "N/A")
}

output "node_group_id_win64" {
    value = try(aws_eks_node_group.windows_amd64[0].id, "N/A")
}

output "p0" {
    value = "-----------------------------------------------------------------"
}
