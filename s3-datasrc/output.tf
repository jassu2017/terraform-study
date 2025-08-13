output "bucket_id" {
    description = "The bucket id"
    value = aws_s3_bucket.example-s3.id
}

output "bucket_name" {
    description = "The bucket name"
    value = aws_s3_bucket.example-s3.bucket
}

output "obj_name" {
    description = "The bucket obj"
    value = aws_s3_object.object.key
}


output "object_info" {
  value = {
    bucket              = data.aws_s3_object.demo-s3-datasrc.bucket
    key                = data.aws_s3_object.demo-s3-datasrc.key
    etag               = data.aws_s3_object.demo-s3-datasrc.etag
    last_modified      = data.aws_s3_object.demo-s3-datasrc.last_modified
    content_length     = data.aws_s3_object.demo-s3-datasrc.content_length
    content_type       = data.aws_s3_object.demo-s3-datasrc.content_type
    storage_class      = data.aws_s3_object.demo-s3-datasrc.storage_class
    server_side_encryption = data.aws_s3_object.demo-s3-datasrc.server_side_encryption
  }
}