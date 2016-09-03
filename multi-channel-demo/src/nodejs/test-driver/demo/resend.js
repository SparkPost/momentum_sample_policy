

function storeSuccess(sourceType, requestPath, transmissionData, response) {
    itemId = nextId();
    var timeStamp = new Date().getTime();
    //console.log(timeStamp + " storeSuccess: " + itemId);
    
    var payload = {
        "source":sourceType,
        "type":"transmission",
        "result":"success",
        "timestamp":timeStamp,
        "requestPath":requestPath,
        "sent":transmissionData,
        "response":response
    };
    
    var key = "tx_" + itemId;
    //console.log("Will store (success) " + key + ": " + JSON.stringify(payload));
    localStorage.setItem(key, JSON.stringify(payload));
    
    rowAddedEvent(key);
}

function storeError(sourceType, requestPath, transmissionData, errorText) {
    itemId = nextId();
    var timeStamp = new Date().getTime();
    //console.log(timeStamp + " storeError: " + itemId);
    var payload = {
            "source":sourceType,
            "type":"transmission",
            "result":"error",
            "timestamp":timeStamp,
            "requestPath":requestPath,
            "sent":transmissionData,
            "errorText":errorText
        };
    //console.log("Will store (error)" + itemId + ": " + JSON.stringify(payload));
    var key = "tx_" + itemId;
    localStorage.setItem(key, JSON.stringify(payload));
    
    rowAddedEvent(key);
}

function resendKey(key) {
    itemId = nextId();
    var payload = localStorage[key];
    var jsonObject = JSON.parse(payload);
    
    return sendToServer("resend_" + jsonObject['source'], jsonObject['requestPath'], jsonObject['sent']);
}

function dumpStore() {
    for (var key in localStorage){
       console.log(key)
    }    
}

function clearStore() {
    localStorage.clear();
}

function nextId() {
    if (localStorage.itemCount) {
        localStorage.itemCount = Number(localStorage.itemCount) + 1;
    } else {
        localStorage.itemCount = 1;
    }
    return localStorage.itemCount;
}

function rowAddedEvent(keyName) {
    var rowAdded = new CustomEvent('rowAdded', { "detail": {"keyName":keyName} });
    document.body.dispatchEvent(rowAdded);
}
