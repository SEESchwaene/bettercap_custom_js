// sudo bettercap -iface pi1eth0









// Declare an array to store incomplete data
var incompleteData = {};

// Function called when data is available
// This function will process the data and extract the URL
function onData(from, to, data) {
    var urlStart = data.indexOf("GET ");
    if (urlStart !== -1) {
        var urlEnd = data.indexOf(" HTTP", urlStart);
        if (urlEnd !== -1) {
            var urlBytes = data.slice(urlStart + 4, urlEnd);
            var url = urlBytes.toString("utf-8");

            console.log("Gefundene URL:", url);
        }
    }

    // Handle incomplete data (data split across multiple onData calls)
    if (incompleteData[from]) {
        data = Buffer.concat([incompleteData[from], data]);
        delete incompleteData[from];
    }

    var lastLineBreak = data.lastIndexOf('\n');
    if (lastLineBreak !== -1 && lastLineBreak < data.length - 1) {
        incompleteData[from] = data.slice(lastLineBreak + 1);
        data = data.slice(0, lastLineBreak + 1);
    }

    return data;
}