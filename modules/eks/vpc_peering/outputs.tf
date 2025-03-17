output "vpc_peering_id" {
  description = "AWS VPC peering ID."
  value       = resource.aws_vpc_peering_connection.peering.id
}
