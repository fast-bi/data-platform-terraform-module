
# Create AWS Route 53 zone for subdomain
resource "aws_route53_zone" "subdomain" {
  name = "${var.subdomain}.${var.main_domain}"
  
  tags = {
    Name = "Subdomain DNS Zone"
  }
}

# Add NS record in GCP Cloud DNS to delegate subdomain to AWS
resource "google_dns_record_set" "subdomain_delegation" {
  name         = "${var.subdomain}.${var.main_domain}."
  managed_zone = var.gcp_dns_zone_name
  type         = "NS"
  ttl          = 300
  
  rrdatas = [for ns in aws_route53_zone.subdomain.name_servers : "${ns}."]
}

# Output the nameservers for the AWS subdomain
output "aws_nameservers" {
  value = aws_route53_zone.subdomain.name_servers
  description = "Nameservers for the AWS-managed subdomain"
}