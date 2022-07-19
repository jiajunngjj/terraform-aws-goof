#! /bin/bash

snyk iac test env_1/main.tf --rules=iac_custom_rules/bundle.tar.gz
