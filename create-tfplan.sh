#! /bin/bash

terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tf-plan.json
