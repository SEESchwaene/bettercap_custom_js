// custom http.js to alert user after loading http_site

var customJavaScript = '<script>alert("Dies ist eine Testmeldung.");</script>';

function onRequest(req, res) {

    req.headers['User-Agent'] = 'CustomUserAgent';
    req.body = req.body.replace('</head>', customJavaScript + '</head>');
    return req;
    
}

function onResponse(req, res) {
    
    res.body = res.body.replace('</head>', customJavaScript + '</head>');

    return res;
}