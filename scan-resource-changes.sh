#! /bin/bash

snyk iac test tf-plan.json --scan=resource-changes
