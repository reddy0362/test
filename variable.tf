variable "aws_access_key" {
        description = "Access key"
        default     = "AKIAJA62EU55NKONDG4Q"
}

variable "aws_secret_key" {
        description = "secret key"
        default     = "6CIZiAsiWIsGhVLEyy7ogLsWBZxh5PfooJsWVkSD"
}
variable "amiId" {
        description = "AMI ID"
        default     = "ami-0ac019f4fcb7cb7e6"
}

variable "KeyPairName" {
        description = "Key pair Name"
        default     = "demo-vpc"
}

variable "RootVolume" {
        description = "Root Volume"
        default = "10"
}

variable "EbsVolume" {
        description = "EBS Volume"
        default = "10"
}

variable "pwd" {
        description = "RDS Password"
        default = "Passw0rd"
}

variable "bucket_logs" {
        description = "Log Bucket Name"
        default = "shekar111111111111111"
}

variable "rdsInstanceType" {
        default = "db.r3.large"
        description = "Instance Type for RDS"
}

variable "recordName" {
        description = "Name of Record (<recordName>.<hostedzone>) example: example.sample.com"
        default = "example"
}

variable "hostedZone" {
        description = "Name of Hosted Zone"
        default = "sample.com"
}

variable "region" {
        default = "us-east-1"
        description = "Region"
}


variable "deletion_protection" {
    default     = "false"
    description = "Select true for prevention from deletion"
}
variable "engine" {
    default     = "mysql"
    description = "Database engine"
}
variable "engine_version" {
    default     = "5.7"
    description = "Engine Version"
}
variable "instance_class" {
    default     = "db.t2.micro"
    description = "Instance Class for Database"
}
variable "allocated_storage" {
    default     = 10
    description = "Allocated storage for Database"
}
variable "desired_capacity" {
    default     = 1
    description = "Desired Capacity of Auto Scaling Group"
}