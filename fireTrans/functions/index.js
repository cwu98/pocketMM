const functions = require('firebase-functions');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.webhook = functions.https.onRequest((request, response) => {

 // response.send(request.payload);
 console.log("request.body.result.parameters: ",
    request.body);
 // const payload = request.payload;
 // if(payload["webhook_typepayload"] == "TRANSACTIONS" && payload["webhook_code"] == "INITIAL_UPDATE"){

 // }
 // else if(payload["webhook_typepayload"] == "TRANSACTIONS" && payload["webhook_code"] == "HISTORICAL_UPDATE"
 //    && payload["new_transactions"] >= 200){

 // }
 response.send(request.body);


});
