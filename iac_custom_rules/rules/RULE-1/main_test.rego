package rules

import data.lib
import data.lib.testing

test_RULE_1 {
	# array containing test cases where the rule is allowed
	allowed_test_cases := [{
		"want_msgs": [],
		"fixture": "allowed.tf",
	}]

	# array containing cases where the rule is denied
	denied_test_cases := [{
		"want_msgs": ["input.resource.aws_s3_bucket[denied].tags"], # verifies that the correct msg is returned by the denied rule
		"fixture": "denied.tf",
	}]

	test_cases := array.concat(allowed_test_cases, denied_test_cases)
	testing.evaluate_test_cases("RULE-1", "./rules/RULE-1/fixtures", test_cases)
}
