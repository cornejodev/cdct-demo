*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           Collections

*** Variables ***
${CONTRACT_PATH}        /user/123
${CONTRACT_STATUS}      200
${CONTRACT_BODY}        {"id": 123, "name": "Alice"}
${PROVIDER_PORT}        8001
${PROVIDER_URL}         http://localhost:${PROVIDER_PORT}

*** Test Cases ***
Start Provider In Background
    [Documentation]    Start the mock provider server in the background
    Run Process    python    -c
    ...    from http.server import BaseHTTPRequestHandler, HTTPServer;
    ...    import json;
    ...    class H(BaseHTTPRequestHandler):
    ...        def do_GET(self):
    ...            if self.path == '/user/123':
    ...                self.send_response(200);
    ...                self.send_header('Content-Type', 'application/json');
    ...                self.end_headers();
    ...                self.wfile.write(json.dumps({'id': 123, 'name': 'Alice'}).encode());
    ...            else:
    ...                self.send_response(404); self.end_headers();
    ...    HTTPServer(('localhost', 8001), H).serve_forever()
    ...    shell=True
    ...    stdout=NONE
    ...    stderr=NONE
    ...    alias=Provider
    Sleep    1s    # Give server time to start

Consumer Verifies Provider Matches Contract
    Create Session    provider    ${PROVIDER_URL}
    ${resp}=    Get Request    provider    ${CONTRACT_PATH}
    Should Be Equal As Integers    ${resp.status_code}    ${CONTRACT_STATUS}
    ${json}=    To Json    ${resp.text}
    Dictionary Should Contain Value    ${json}    Alice
    Dictionary Should Contain Item    ${json}    id    123

Stop Provider Server
    Terminate All Processes
