# Snyk IaC Demo

* IaC Custom rules
* Snyk IaC scan of Terraform code (static) and Terraform plan
* Drift detection

This repository contains:
* env_1 - Terraform code to spin up AWS S3 Bucket
* env_1_custom_rules_fixed - Terraform code to spin up AWS S3 Bucket with resource tagging 
* env_2 - Terraform code to spin up AWS VPC (this is just to show that Snyk IaC can scan multiple tfstate files)
* iac_custom_rules - Contains custom rules bundle and Rego rules

## Demo #1 - Scanning of Terraform code (static) and Terraform plan

Scanning of the Terraform code (env_1/main.tf) would not include modules and variables:

```
➜ snyk iac test env_1/main.tf

Testing env_1/main.tf...


Infrastructure as code issues:
  ✗ Non-encrypted S3 Bucket [Medium Severity] [SNYK-CC-TF-4] in S3
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo]

  ✗ S3 bucket MFA delete control disabled [Low Severity] [SNYK-CC-TF-127] in S3
    introduced by resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > versioning > mfa_delete

  ✗ S3 bucket versioning disabled [Low Severity] [SNYK-CC-TF-124] in S3
    introduced by resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > versioning > enabled

  ✗ S3 server access logging is disabled [Low Severity] [SNYK-CC-TF-45] in S3
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > logging


Organization:      jj.ng
Type:              Terraform
Target file:       env_1/main.tf
Project name:      env_1
Open source:       no
Project path:      env_1/main.tf

Tested env_1/main.tf for known issues, found 4 issues
```

Now, create a Terraform plan file by doing the follow:
```
➜ cd env_1
➜ terraform plan -out=tfplan.binary
➜ terraform show -json tfplan.binary > tf-plan.json
```

Scanning of the created Terraform Plan would show the ACL variable (public_read_write):
```
➜ snyk iac test tf-plan.json --scan=planned-values

Testing tf-plan.json...


Infrastructure as code issues:
  ✗ S3 Bucket is publicly readable and writable [High Severity] [SNYK-CC-TF-19] in S3
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > acl

  ✗ Non-encrypted S3 Bucket [Medium Severity] [SNYK-CC-TF-4] in S3
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo]

  ✗ S3 bucket MFA delete control disabled [Low Severity] [SNYK-CC-TF-127] in S3
    introduced by resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > versioning > mfa_delete

  ✗ S3 bucket versioning disabled [Low Severity] [SNYK-CC-TF-124] in S3
    introduced by resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > versioning > enabled

  ✗ S3 server access logging is disabled [Low Severity] [SNYK-CC-TF-45] in S3
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > logging


Organization:      jj.ng
Type:              Terraform
Target file:       tf-plan.json
Project name:      env_1
Open source:       no
Project path:      tf-plan.json

Tested tf-plan.json for known issues, found 5 issues
```

## Demo #2 - Custom Rules

iac_custom_rules contains a custom rule which requires users to tag the resource that they are provisioning.

Scanning of env_1/main.tf against the custom rule would flag out the following issue:
```
  ✗ Missing an owner from tag [Medium Severity] [MY_RULE_1]
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > tags
```

Here is the scanned output:
```
➜ snyk iac test env_1/main.tf --rules=iac_custom_rules/bundle.tar.gz
Using custom rules to generate misconfigurations.

Testing env_1/main.tf...


Infrastructure as code issues:
  ✗ Non-encrypted S3 Bucket [Medium Severity] [SNYK-CC-TF-4] in S3
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo]

  ✗ Missing an owner from tag [Medium Severity] [MY_RULE_1]
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > tags

  ✗ S3 bucket MFA delete control disabled [Low Severity] [SNYK-CC-TF-127] in S3
    introduced by resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > versioning > mfa_delete

  ✗ S3 bucket versioning disabled [Low Severity] [SNYK-CC-TF-124] in S3
    introduced by resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > versioning > enabled

  ✗ S3 server access logging is disabled [Low Severity] [SNYK-CC-TF-45] in S3
    introduced by input > resource > aws_s3_bucket[jj-s3-bucket-iac-demo] > logging


Organization:      jj.ng
Type:              Terraform
Target file:       env_1/main.tf
Project name:      env_1
Open source:       no
Project path:      env_1/main.tf

Tested env_1/main.tf for known issues, found 5 issues
```
The fix is to have a resource tagging. The main.tf in env_1_custom_rules_fixed has the resource tagging in placed which would not trigger the custom rule:
```
resource "aws_s3_bucket" "jj-s3-demo"{
  bucket = "jjdata"
  acl = var.s3_acl
  tags {
    owner = JJ
  }
}
```

## Demo #3 - Drift detection
1. Provision the AWS S3 Bucket service in env_1. Note that my region is in 'ap-southeast-1'.

2. Head over to your AWS console and add a new tag to the jj-terraform-s3-goof-bucket e.g owner=jj

3. Run the following command to detect the drift in configurations:

```
snyk iac describe --only-managed
Scanned states (1)
Scan duration: 2m43s
Provider version used to scan: 4.24.0. Use --tf-provider-version to use another version.
Snyk Scanning Infrastructure As Code Discrepancies...

  Info:    Resources under IaC, but different to terraform states.
  Resolve: Reapply IaC resources or update into terraform.

Changed resources: 1

State: tfstate://terraform.tfstate [ Changed Resources: 1 ]

  Resource Type: aws_s3_bucket
    ID: jj-terraform-s3-goof-bucket
    - grant: [{"id":"","permissions":["READ","WRITE"],"type":"Group","uri":"http://acs.amazonaws.com/groups/global/AllUsers"},{"id":"14885a40519d92132132132143242543trret435","permissions":["FULL_CONTROL"],"type":"CanonicalUser","uri":""}]
    + tags: null => {"owner":"jj"}

Test Summary

  Managed Resources: 1
  Changed Resources: 1

  IaC Coverage: 100%
  Info: To reach full coverage, remove resources or move it to Terraform.

  Tip: Run --help to find out about commands and flags.
      Scanned with aws provider version 4.24.0. Use --tf-provider-version to update.
```

you will see that it detects the managed resources by comparing with the tfstate file.
