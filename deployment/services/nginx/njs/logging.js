function downstream_request_headers_json(r) {
    return JSON.stringify(r.headersIn).toString('base64');
}

function downstream_response_headers_json(r) {
    return JSON.stringify(r.headersOut);
}
