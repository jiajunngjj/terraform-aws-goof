package rules

deny[msg] {
    resource := input.resource.aws_s3_bucket[name]
    not resource.tags.owner

    msg := {
        "publicId": "MY_RULE_1",
        "title": "Missing an owner from tag",
        "severity": "medium",
        "msg": sprintf("input.resource.aws_s3_bucket[%s].tags", [name]),
        "issue": "",
        "impact": "",
        "remediation": "",
        "references": [],
    }
}
