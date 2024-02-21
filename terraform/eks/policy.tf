resource "aws_iam_role" "eks-iam-node" {
    name               = "eks-iam-node-${random_id.aws-prefix.hex}"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = { Service = "eks.amazonaws.com" }
        }]
    })
}


resource "aws_iam_role" "eks-iam-nodegroup" {
    name               = "eks-iam-nodegroup-${random_id.aws-prefix.hex}"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
        }]
    })
}

resource "aws_iam_role_policy_attachment" "eks-iam-node-AmazonEKSClusterPolicy" {
    role       = "${aws_iam_role.eks-iam-node.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role_policy_attachment" "eks-iam-node-AmazonEKSServicePolicy" {
    role       = "${aws_iam_role.eks-iam-node.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}


resource "aws_iam_role_policy_attachment" "eks-iam-nodegroup-AmazonEKSWorkerNodePolicy" {
    role       = "${aws_iam_role.eks-iam-nodegroup.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "eks-iam-nodegroup-AmazonEKS_CNI_Policy" {
    role       = "${aws_iam_role.eks-iam-nodegroup.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


resource "aws_iam_role_policy_attachment" "eks-iam-nodegroup-AmazonEC2ContainerRegistryReadOnly" {
    role       = "${aws_iam_role.eks-iam-nodegroup.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_iam_role_policy_attachment" "eks-iam-nodegroup-AmazonEBSCSIDriverPolicy" {
    role       = "${aws_iam_role.eks-iam-nodegroup.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
