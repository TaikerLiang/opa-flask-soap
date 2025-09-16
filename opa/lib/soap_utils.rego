package lib.soap

import future.keywords.if

# Calls the Flask SOAP endpoint and returns {"name": string, "age": number}
lookup_user_from_soap(user_id) = out if {
  print("=== SOAP Request Start ===")
  print(sprintf("Looking up user_id: %s", [user_id]))

  envelope := sprintf(`<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="https://example.com/user">
  <soapenv:Header/>
  <soapenv:Body>
    <u:GetUserRequest>
      <u:UserId>%s</u:UserId>
    </u:GetUserRequest>
  </soapenv:Body>
</soapenv:Envelope>`, [user_id])

  print(sprintf("SOAP envelope: %s", [envelope]))

  resp := http.send({
    "method": "post",
    "url": "http://soap-flask:5000/soap/user",
    "headers": {
      "Content-Type": "text/xml; charset=utf-8",
      "SOAPAction": "GetUser"
    },
    "body": envelope,
    "timeout": "3s",
    "raise_error": true
  })

  print(sprintf("HTTP Response Status: %d", [resp.status]))
  print(sprintf("HTTP Response Headers: %v", [resp.headers]))
  print(sprintf("HTTP Response Body: %s", [resp.raw_body]))

  resp.status == 200
  xml := resp.raw_body

  name := xml_tag_value(xml, "Name")
  age_str := xml_tag_value(xml, "Age")

  print(sprintf("Parsed Name: %s, Age: %s", [name, age_str]))

  out := {"name": name, "age": to_number(age_str)}

  print(sprintf("Final output: %v", [out]))
  print("=== SOAP Request End ===")
}

# Minimal <Tag>...</Tag> extractor (first match)
xml_tag_value(xml, tag) = val if {
  start := concat("", ["<", tag, ">"])
  stop  := concat("", ["</", tag, ">"])
  s := indexof(xml, start)
  e := indexof(xml, stop)
  s >= 0
  e > s
  inner := substring(xml, s + count(start), e - (s + count(start)))
  val := trim(inner, " \t\r\n")
}