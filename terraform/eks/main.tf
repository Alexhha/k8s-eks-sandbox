resource "random_id" "aws-prefix" {
    byte_length = 4
}


resource "aws_key_pair" "ssh_public_key" {
    key_name   = "k8s-eks-sandbox-${random_id.aws-prefix.hex}"
    public_key = file("./files/k8s-eks-sandbox.pub")
}


resource "aws_eks_cluster" "k8s-cluster" {
    name     = "eks-sandbox-${random_id.aws-prefix.hex}"
    version  = var.k8s_version
    role_arn = aws_iam_role.eks-iam-node.arn

    vpc_config {
        subnet_ids         = ["subnet-0e5b933658deb9bdd", "subnet-0375b5fa4575e0964"]
        security_group_ids = [aws_security_group.eks-cluster-security-group.id]
    }

    kubernetes_network_config {
        service_ipv4_cidr = "192.168.128.0/24"
        ip_family         = "ipv4"
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks-iam-node-AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.eks-iam-node-AmazonEKSServicePolicy,
    ]
}


resource "aws_security_group" "eks-cluster-security-group" {
    name        = "eks-cluster-${random_id.aws-prefix.hex}"
    description = "AWS freetier tests default security group"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        self        = true
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.whitelist_ips
        description = "AWS freetier whitelist"
    }
}


resource "null_resource" "output" {
    triggers = {
        template_rendered = "${data.template_file.kube_config.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.kube_config.rendered}' > kubeconfig.aws"
    }
}


resource "null_resource" "wait_for_k8s_cluster" {
    depends_on = [aws_eks_cluster.k8s-cluster]

    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]

        command = <<EOT
            RVAL=$(curl -k -s $ENDPOINT/healthz)
            while [[ $RVAL != 'ok' ]]
            do
                sleep 10
                RVAL=$(curl -k -s $ENDPOINT/healthz)
            done
        EOT

        environment = {
            ENDPOINT = "${aws_eks_cluster.k8s-cluster.endpoint}"
        }
    }
}
