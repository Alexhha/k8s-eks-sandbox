locals {
    ami_distro_filter = {
        amd64 = {
            al2    = "amazon-eks-node-${var.k8s_version}-*"
            ubuntu = "ubuntu-eks/k8s_${var.k8s_version}/images/hvm-ssd/ubuntu-*-amd64-server*"
        }
        arm64 = {
            al2    = "amazon-eks-arm64-node-${var.k8s_version}-*"
            ubuntu = "ubuntu-eks/k8s_${var.k8s_version}/images/hvm-ssd/ubuntu-*-arm64-server*"
        }
    }
}
