#! /bin/bash

snyk iac describe --all --filter=Attr.region==\'ap-southeast-1\' --from="tfstate://env_1/terraform.tfstate"
