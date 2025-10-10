variable "region" {

  description = "AWS region for s3"
  type = string
  default = "ap-south-1"
  
}

variable "bucket_name"{

  description = "name of the for s3"
  type = string
  default = "demo-bkt-101025"

}

variable "s3_bucket_key_name" {
  description = "name of the for s3 object key"
  type = string
  default = "demo-bkt-101025-key"
 
}