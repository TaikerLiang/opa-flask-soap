package lib.soap

import future.keywords.if

# Calls the Flask SOAP endpoint and returns {"name": string, "age": number}
lookup_user_from_soap(user_id) = out if {
  envelope := sprintf(`<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="https://example.com/user">
  <soapenv:Header/>
  <soapenv:Body>
    <u:GetUserRequest>
      <u:UserId>%s</u:UserId>
    </u:GetUserRequest>
  </soapenv:Body>
</soapenv:Envelope>`, [user_id])

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

  resp.status == 200
  xml := resp.raw_body

  name := xml_tag_value(xml, "Name")
  age_str := xml_tag_value(xml, "Age")

  out := {"name": name, "age": to_number(age_str)}
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