const functions = require('firebase-functions');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
const firebase = require("firebase");
// Required for side-effects
require("firebase/firestore");



'use strict';

var util = require('util');

var envvar = require('envvar');
var express = require('express');
var bodyParser = require('body-parser');
var moment = require('moment');
var plaid = require('plaid');
const fs = require('fs');

var APP_PORT = envvar.number('APP_PORT', 8000);
var PLAID_CLIENT_ID = envvar.string('PLAID_CLIENT_ID');
var PLAID_SECRET = envvar.string('PLAID_SECRET');
var PLAID_PUBLIC_KEY = envvar.string('PLAID_PUBLIC_KEY');
var PLAID_ENV = envvar.string('PLAID_ENV', 'sandbox');
// PLAID_PRODUCTS is a comma-separated list of products to use when initializing
// Link. Note that this list must contain 'assets' in order for the app to be
// able to create and retrieve asset reports.
var PLAID_PRODUCTS = envvar.string('PLAID_PRODUCTS', 'transactions');

// PLAID_PRODUCTS is a comma-separated list of countries for which users
// will be able to select institutions from.
var PLAID_COUNTRY_CODES = envvar.string('PLAID_COUNTRY_CODES', 'US,CA,GB,FR,ES,IE,NL');

// Parameters used for the OAuth redirect Link flow.
//
// Set PLAID_OAUTH_REDIRECT_URI to 'http://localhost:8000/oauth-response.html'
// The OAuth redirect flow requires an endpoint on the developer's website
// that the bank website should redirect to. You will need to whitelist
// this redirect URI for your client ID through the Plaid developer dashboard
// at https://dashboard.plaid.com/team/api.
var PLAID_OAUTH_REDIRECT_URI = envvar.string('PLAID_OAUTH_REDIRECT_URI', '');
// Set PLAID_OAUTH_NONCE to a unique identifier such as a UUID for each Link
// session. The nonce will be used to re-open Link upon completion of the OAuth
// redirect. The nonce must be at least 16 characters long.
var PLAID_OAUTH_NONCE = envvar.string('PLAID_OAUTH_NONCE', '');

// We store the access_token in memory - in production, store it in a secure
// persistent data store
var ACCESS_TOKEN = null;
var PUBLIC_TOKEN = null;
var ITEM_ID = null;


// Initialize the Plaid client
// Find your API keys in the Dashboard (https://dashboard.plaid.com/account/keys)
var client = new plaid.Client(
  PLAID_CLIENT_ID,
  PLAID_SECRET,
  PLAID_PUBLIC_KEY,
  plaid.environments[PLAID_ENV],
  {version: '2019-05-29', clientApp: 'Plaid Quickstart'}
);

var app = express();
app.use(bodyParser.urlencoded({
  extended: false
}));
app.use(bodyParser.json());
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


var server = app.listen(APP_PORT, function() {
  console.log('plaid-quickstart server listening on port ' + APP_PORT);
});

var prettyPrintResponse = response => {
  console.log(util.inspect(response, {colors: true, depth: 4}));
};


LWh-Tf-cH1
Gtu-7J-kr3
eP0-uy-mkm
