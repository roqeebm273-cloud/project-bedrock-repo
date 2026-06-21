resource "aws_eks_addon" "cloudwatch" {
cluster_name = module.eks.cluster_name
addon_name = "amazon-cloudwatch-observability"
addon_version = null
}
