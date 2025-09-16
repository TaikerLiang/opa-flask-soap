package test_data

# Test data for various scenarios used across test files

# Sample SOAP responses for different users
soap_responses := {
    "alice": `<?xml version="1.0" encoding="UTF-8"?>
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

    "bob": `<?xml version="1.0" encoding="UTF-8"?>
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

    "carol": `<?xml version="1.0" encoding="UTF-8"?>
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

    "unknown": `<?xml version="1.0" encoding="UTF-8"?>
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
</soap:Envelope>`
}

# Error response samples
error_responses := {
    "internal_server_error": {
        "status": 500,
        "raw_body": "Internal Server Error",
        "headers": {"content-type": ["text/plain"]}
    },

    "not_found": {
        "status": 404,
        "raw_body": "Not Found",
        "headers": {"content-type": ["text/plain"]}
    },

    "bad_request": {
        "status": 400,
        "raw_body": "Bad Request",
        "headers": {"content-type": ["text/plain"]}
    },

    "timeout": {
        "status": 408,
        "raw_body": "Request Timeout",
        "headers": {"content-type": ["text/plain"]}
    }
}

# Malformed XML responses for error testing
malformed_responses := {
    "missing_name": `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <u:UserId>test</u:UserId>
        <Age>25</Age>
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>`,

    "missing_age": `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <u:UserId>test</u:UserId>
        <Name>TestUser</Name>
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>`,

    "invalid_xml": `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <u:UserId>test</u:UserId>
        <Name>TestUser
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>`,

    "empty_response": "",

    "non_xml": "This is not XML content"
}

# Test user scenarios
user_scenarios := [
    {
        "user_id": "u1",
        "expected_name": "Alice",
        "expected_age": 30,
        "should_be_allowed": false,
        "description": "Alice should be denied access"
    },
    {
        "user_id": "u2",
        "expected_name": "Bob",
        "expected_age": 28,
        "should_be_allowed": true,
        "description": "Bob should be allowed access"
    },
    {
        "user_id": "u3",
        "expected_name": "Carol",
        "expected_age": 34,
        "should_be_allowed": true,
        "description": "Carol should be allowed access"
    },
    {
        "user_id": "unknown",
        "expected_name": "Unknown",
        "expected_age": 0,
        "should_be_allowed": true,
        "description": "Unknown user should be allowed (not Alice)"
    }
]

# Case sensitivity test data for Alice
alice_case_variations := [
    "alice",
    "Alice",
    "ALICE",
    "aLiCe",
    "AlIcE",
    "aLICE",
    "ALice"
]

# Edge case inputs for testing
edge_case_inputs := [
    {},
    {"user_id": ""},
    {"user_id": null},
    {"other_field": "value"},
    {"user_id": "   "},
    {"user_id": "nonexistent"}
]

# Expected HTTP request structure for validation
expected_soap_request := {
    "method": "post",
    "url": "http://soap-flask:5000/soap/user",
    "headers": {
        "Content-Type": "text/xml; charset=utf-8",
        "SOAPAction": "GetUser"
    },
    "timeout": "3s",
    "raise_error": true
}