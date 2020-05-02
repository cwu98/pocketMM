const functions = require('firebase-functions');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
const firebase = require("firebase");
// Required for side-effects
require("firebase/firestore");

// Initialize Cloud Firestore through Firebase
firebase.initializeApp({
  apiKey: '### FIREBASE API KEY ###',
  authDomain: '### FIREBASE AUTH DOMAIN ###',
  projectId: '### CLOUD FIRESTORE PROJECT ID ###'
});

var db = firebase.firestore();

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

var user = firebase.auth().currentUser;

if (user) {
  var userRef = db.collection("users").doc(user.email);

// Atomically add a new region to the "regions" array field.
userRef.update({
    transactions: firebase.firestore.FieldValue.arrayUnion()
});
} else {
  // No user is signed in.
}



 response.send(request.body);


});

// Retrieve Transactions for an Item
// https://plaid.com/docs/#transactions
app.get('/transactions', function(request, response, next) {
  // Pull transactions for the Item for the last 30 days
  var startDate = moment().subtract(30, 'days').format('YYYY-MM-DD');
  var endDate = moment().format('YYYY-MM-DD');
  client.getTransactions(ACCESS_TOKEN, startDate, endDate, {
    count: 250,
    offset: 0,
  }, function(error, transactionsResponse) {
    if (error != null) {
      prettyPrintResponse(error);
      return response.json({
        error: error
      });
    } else {
      prettyPrintResponse(transactionsResponse);
      response.json({error: null, transactions: transactionsResponse});
    }
  });
});


// Retrieve real-time Balances for each of an Item's accounts
// https://plaid.com/docs/#balance
app.get('/balance', function(request, response, next) {
  client.getBalance(ACCESS_TOKEN, function(error, balanceResponse) {
    if (error != null) {
      prettyPrintResponse(error);
      return response.json({
        error: error,
      });
    }
    prettyPrintResponse(balanceResponse);
    response.json({error: null, balance: balanceResponse});
  });
});
