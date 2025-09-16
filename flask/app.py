from flask import Flask, request, Response

app = Flask(__name__)

# Simple in-memory "directory"
USERS = {
    "u1": {"name": "Alice", "age": 30},
    "u2": {"name": "Bob",   "age": 28},
    "u3": {"name": "Carol", "age": 34},
}

@app.get("/healthz")
def healthz():
    return "ok", 200

def extract_between(text, start_tag, end_tag):
    s = text.find(start_tag)
    e = text.find(end_tag)
    if s == -1 or e == -1 or e <= s:
        return ""
    inner = text[s + len(start_tag) : e]
    return inner.strip()

@app.post("/soap/user")
def soap_user():
    """
    Very small SOAP-like endpoint:
    - Expects text/xml POST body with <UserId>...</UserId> (or <u:UserId>...</u:UserId>)
    - Returns SOAP envelope with <Name> and <Age>
    """
    xml = request.data.decode("utf-8") if request.data else ""
    # try both namespaced and non-namespaced tags
    user_id = extract_between(xml, "<UserId>", "</UserId>")
    if not user_id:
        user_id = extract_between(xml, "<u:UserId>", "</u:UserId>")

    user = USERS.get(user_id, {"name": "Unknown", "age": 0})

    response_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:u="https://example.com/user">
  <soap:Body>
    <u:GetUserResponse>
      <u:User>
        <u:UserId>{user_id}</u:UserId>
        <Name>{user['name']}</Name>
        <Age>{user['age']}</Age>
      </u:User>
    </u:GetUserResponse>
  </soap:Body>
</soap:Envelope>
"""
    return Response(response_xml, status=200, mimetype="text/xml")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)