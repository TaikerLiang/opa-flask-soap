package authz

import data.lib.soap
import future.keywords.if

# Mock HTTP responses for authorization tests
mock_alice_response := {
    "status": 200,
    "raw_body": `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="https://example.com/user">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <u:UserId>u1</u:UserId>
        <Name>Alice</Name>
        <Age>30</Age>
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>`,
    "headers": {"content-type": ["text/xml; charset=utf-8"]}
}

mock_bob_response := {
    "status": 200,
    "raw_body": `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="https://example.com/user">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <u:UserId>u2</u:UserId>
        <Name>Bob</Name>
        <Age>28</Age>
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>`,
    "headers": {"content-type": ["text/xml; charset=utf-8"]}
}

mock_carol_response := {
    "status": 200,
    "raw_body": `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="https://example.com/user">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <u:UserId>u3</u:UserId>
        <Name>Carol</Name>
        <Age>34</Age>
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>`,
    "headers": {"content-type": ["text/xml; charset=utf-8"]}
}

mock_unknown_response := {
    "status": 200,
    "raw_body": `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="https://example.com/user">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <u:UserId>unknown</u:UserId>
        <Name>Unknown</Name>
        <Age>0</Age>
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>`,
    "headers": {"content-type": ["text/xml; charset=utf-8"]}
}

# Mock HTTP send that returns responses based on request body
mock_http_send(request) := response if {
    contains(request.body, "u1")
    response := mock_alice_response
} else := response if {
    contains(request.body, "u2")
    response := mock_bob_response
} else := response if {
    contains(request.body, "u3")
    response := mock_carol_response
} else := mock_unknown_response

# Test Alice is denied (case insensitive)
test_alice_denied if {
    not allow with input.user_id as "u1"
        with http.send as mock_http_send
}

# Helper function for uppercase Alice response
mock_alice_upper_func(req) := object.union(mock_alice_response, {
    "raw_body": replace(mock_alice_response.raw_body, "<Name>Alice</Name>", "<Name>ALICE</Name>")
})

# Test Alice is denied with different case variations
test_alice_denied_case_variations if {
    not allow with input.user_id as "u1"
        with http.send as mock_alice_upper_func
}

# Test Bob is allowed
test_bob_allowed if {
    allow with input.user_id as "u2"
        with http.send as mock_http_send
}

# Test Carol is allowed
test_carol_allowed if {
    allow with input.user_id as "u3"
        with http.send as mock_http_send
}

# Test unknown user is allowed (since name is "Unknown", not "alice")
test_unknown_user_allowed if {
    allow with input.user_id as "unknown"
        with http.send as mock_http_send
}

# Test missing user_id in input
test_missing_user_id_denied if {
    not allow with input as {}
}

# Test empty user_id returns Unknown user, which should be allowed
test_empty_user_id_gets_unknown if {
    allow with input.user_id as ""
        with http.send as mock_http_send
}

# Test authorization scenarios with different users
test_authorization_scenarios if {
    scenarios := [
        {"user_id": "u1", "name": "Alice", "should_allow": false},
        {"user_id": "u2", "name": "Bob", "should_allow": true},
        {"user_id": "u3", "name": "Carol", "should_allow": true}
    ]

    scenario := scenarios[_]
    result := allow with input.user_id as scenario.user_id
        with http.send as mock_http_send

    # Verify the result matches expectation
    result == scenario.should_allow
}

# Helper function for lowercase Alice
mock_alice_lowercase_func(req) := object.union(mock_alice_response, {
    "raw_body": replace(mock_alice_response.raw_body, "<Name>Alice</Name>", "<Name>alice</Name>")
})

# Test case sensitivity of Alice blocking (lowercase)
test_alice_case_sensitivity_lowercase if {
    not allow with input.user_id as "u1"
        with http.send as mock_alice_lowercase_func
}

# Helper function for error response
mock_error_func(req) := {
    "status": 500,
    "raw_body": "Internal Server Error",
    "headers": {"content-type": ["text/plain"]}
}

# Test that authorization rule works when SOAP lookup fails
test_http_error_handling if {
    # When HTTP call fails, the rule should not match and allow should be false
    not allow with input.user_id as "u1"
        with http.send as mock_error_func
}

# Test the default allow value
test_default_allow_is_false if {
    not allow with input as {}
}

# Test that rule requires user_id in input
test_requires_user_id if {
    # Without user_id, the allow rule should not match
    not allow with input as {"other_field": "value"}
        with http.send as mock_http_send
}