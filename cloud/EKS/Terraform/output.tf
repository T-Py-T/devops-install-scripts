output "cluster_id" {
  value = aws_eks_cluster.devopstesting.id
}

output "node_group_id" {
  value = aws_eks_node_group.devopstesting.id
}

output "vpc_id" {
  value = aws_vpc.devopstesting_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.devopstesting_subnet[*].id
}
