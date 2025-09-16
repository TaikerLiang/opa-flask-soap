package lib.soap

import future.keywords.if

# Mock HTTP responses for different users
mock_http_alice := {
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
    "headers": {
        "content-type": ["text/xml; charset=utf-8"],
        "content-length": ["352"]
    }
}

mock_http_bob := {
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
    "headers": {
        "content-type": ["text/xml; charset=utf-8"],
        "content-length": ["350"]
    }
}

mock_http_carol := {
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
    "headers": {
        "content-type": ["text/xml; charset=utf-8"],
        "content-length": ["352"]
    }
}

mock_http_unknown := {
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
    "headers": {
        "content-type": ["text/xml; charset=utf-8"],
        "content-length": ["355"]
    }
}

mock_http_error_500 := {
    "status": 500,
    "raw_body": "Internal Server Error",
    "headers": {
        "content-type": ["text/plain"]
    }
}

mock_http_error_404 := {
    "status": 404,
    "raw_body": "Not Found",
    "headers": {
        "content-type": ["text/plain"]
    }
}

mock_http_malformed_xml := {
    "status": 200,
    "raw_body": `<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <MissingName>test</MissingName>
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>`,
    "headers": {
        "content-type": ["text/xml; charset=utf-8"]
    }
}

# Mock function that returns different responses based on the request
mock_http_send(request) := response if {
    contains(request.body, "u1")
    response := mock_http_alice
} else := response if {
    contains(request.body, "u2")
    response := mock_http_bob
} else := response if {
    contains(request.body, "u3")
    response := mock_http_carol
} else := response if {
    contains(request.body, "unknown")
    response := mock_http_unknown
} else := response if {
    contains(request.body, "error500")
    response := mock_http_error_500
} else := response if {
    contains(request.body, "error404")
    response := mock_http_error_404
} else := response if {
    contains(request.body, "malformed")
    response := mock_http_malformed_xml
} else := mock_http_unknown

# Test successful user lookup - Alice
test_lookup_user_alice_success if {
    result := lookup_user_from_soap("u1") with http.send as mock_http_send
    result.name == "Alice"
    result.age == 30
}

# Test successful user lookup - Bob
test_lookup_user_bob_success if {
    result := lookup_user_from_soap("u2") with http.send as mock_http_send
    result.name == "Bob"
    result.age == 28
}

# Test successful user lookup - Carol
test_lookup_user_carol_success if {
    result := lookup_user_from_soap("u3") with http.send as mock_http_send
    result.name == "Carol"
    result.age == 34
}

# Test unknown user lookup
test_lookup_user_unknown if {
    result := lookup_user_from_soap("unknown") with http.send as mock_http_send
    result.name == "Unknown"
    result.age == 0
}

# Test XML tag extraction
test_xml_tag_value_extraction if {
    xml := `<root><Name>TestUser</Name><Age>25</Age></root>`
    xml_tag_value(xml, "Name") == "TestUser"
    xml_tag_value(xml, "Age") == "25"
}

# Test XML tag extraction with whitespace
test_xml_tag_value_whitespace if {
    xml := `<root><Name>  TestUser  </Name></root>`
    xml_tag_value(xml, "Name") == "TestUser"
}

# Test XML tag extraction - missing tag
test_xml_tag_value_missing if {
    xml := `<root><Other>value</Other></root>`
    not xml_tag_value(xml, "Name")
}

# Test multiple test scenarios in a parameterized way
test_user_scenarios if {
    scenarios := [
        {"user_id": "u1", "expected_name": "Alice", "expected_age": 30},
        {"user_id": "u2", "expected_name": "Bob", "expected_age": 28},
        {"user_id": "u3", "expected_name": "Carol", "expected_age": 34}
    ]

    scenario := scenarios[_]
    result := lookup_user_from_soap(scenario.user_id) with http.send as mock_http_send
    result.name == scenario.expected_name
    result.age == scenario.expected_age
}