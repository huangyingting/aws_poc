output "primary_rds_address" {
  value = aws_db_instance.mysql.address
}

output "secondary_rds_address" {
  value = aws_db_instance.mysql_replica.address
}

output "primary_s3_bucket" {
  value = aws_s3_bucket.primary.bucket_domain_name
}

output "failover_s3_bucket" {
  value = aws_s3_bucket.failover.bucket_domain_name
}

output "ssh_to_jumpbox" {
  value = "ssh -i ${local_file.my_key_file.filename} ubuntu@${aws_instance.jumpbox.public_ip}"
}

output "show_replica_status" {
  value = "echo 'show slave status' | mysql -h ${aws_db_instance.mysql_replica.address} -u admin -p"
}

output "web_address" {
  value = "https://aws.cnpro.org"
}

output "cloudfront_address" {
  value = "https://${aws_cloudfront_distribution.cloudfront.domain_name}"
}

output "web_elb_addess" {
  value = "http://${aws_elb.web.dns_name}"
}

output "phpadmin_elb_addess" {
  value = "http://${aws_elb.web.dns_name}:8080"
}