

function sendToServer(source, serverPath, jsonData) {
    $.ajax({
        beforeSend: function(xhrObj){
            xhrObj.setRequestHeader("Content-Type","application/json");
            xhrObj.setRequestHeader("Accept","application/json");
        },
        type: "POST",
        url: serverPath,
        data:jsonData,
        dataType: "json",
        success: function(json){
            console.log(JSON.stringify(json));
            storeSuccess(source, serverPath, jsonData, JSON.stringify(json));
        },
        error: function (textStatus, errorThrown) {
            console.log("ERROR: " + textStatus);   
            storeError(source, serverPath, jsonData, textStatus);
        }
    });
}