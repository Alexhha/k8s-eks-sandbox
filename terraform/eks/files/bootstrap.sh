#!/bin/bash

# https://github.com/awslabs/amazon-eks-ami/blob/master/files/max-pods-calculator.sh
/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args '--max-pods=20' --use-max-pods false
