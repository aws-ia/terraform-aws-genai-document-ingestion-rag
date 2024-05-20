output "access_logs_bucket_id" {
  value = aws_s3_bucket.access_logs_bucket.id
}
output "access_logs_bucket_arn" {
  value = aws_s3_bucket.access_logs_bucket.arn
}

output "input_assets_bucket_id" {
  value = aws_s3_bucket.input_assets_bucket.id
}
output "input_assets_bucket_arn" {
  value = aws_s3_bucket.input_assets_bucket.arn
}

output "processed_assets_bucket_id" {
  value = aws_s3_bucket.processed_assets_bucket.id
}
output "processed_assets_bucket_arn" {
  value = aws_s3_bucket.processed_assets_bucket.arn
}