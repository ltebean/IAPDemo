## Some work in itunesconnect

* Create an app with an id, for example: com.test.app
* Create some iap product, the id of the product may be: "com.test.app.iap.coins1"
* Create a sandbox user to test iap


## Manage IAP product

On the server side, we need a table to store all the product info, the schema is:
```
id | product_id | title | description | coins | enabled | time_created | time_updated
```

* product_id: the iap's id registered in itunesconnect
* title: the product's title
* description: the product's description
* coins: the corresponding coins that will be given to the user 

After register all the iap product in itunesconnect, insert the corresponding record into this table, when the client enters the purchase page, it will fetch all the enabled product in this table and then display them to the user.


## Handle transaction

We also need a table to store all the transactions
```
id | transaction_id | product_id | user_id | time_created | time_updated
```
* transaction_id: the transaction id, we can get it from the iap receipt
* product_id: which product
* user_id: who bought the product


When client finishes a purchase, we will get a transactionId, we should save it first.

Then, we send the transactionId along with the receipt to our server, the server then sends the receipt to apple's server to verify it. It's a POST request, the url is:

* sandbox: https://sandbox.itunes.apple.com/verifyReceipt 
* product: https://buy.itunes.apple.com/verifyReceipt

The body is 
```json
{
   "receipt-data": "the receipt string sent by the client"
}
```
A sample response: 
```json
{
  "status": 0,
  "environment": "Sandbox",
  "receipt": {
    "receipt_type": "ProductionSandbox",
    "adam_id": 0,
    "app_item_id": 0,
    "bundle_id": "io.ltebean.iapdemo",
    "application_version": "1",
    "download_id": 0,
    "version_external_identifier": 0,
    "receipt_creation_date": "2016-10-10 06:41:00 Etc/GMT",
    "receipt_creation_date_ms": "1476081660000",
    "receipt_creation_date_pst": "2016-10-09 23:41:00 America/Los_Angeles",
    "request_date": "2016-10-10 06:44:18 Etc/GMT",
    "request_date_ms": "1476081858144",
    "request_date_pst": "2016-10-09 23:44:18 America/Los_Angeles",
    "original_purchase_date": "2013-08-01 07:00:00 Etc/GMT",
    "original_purchase_date_ms": "1375340400000",
    "original_purchase_date_pst": "2013-08-01 00:00:00 America/Los_Angeles",
    "original_application_version": "1.0",
    "in_app": [
      {
        "quantity": "1",
        "product_id": "io.ltebean.iapdemo.iap1",
        "transaction_id": "1000000241260292",
        "original_transaction_id": "1000000241260292",
        "purchase_date": "2016-10-10 06:34:34 Etc/GMT",
        "purchase_date_ms": "1476081274000",
        "purchase_date_pst": "2016-10-09 23:34:34 America/Los_Angeles",
        "original_purchase_date": "2016-10-10 06:34:34 Etc/GMT",
        "original_purchase_date_ms": "1476081274000",
        "original_purchase_date_pst": "2016-10-09 23:34:34 America/Los_Angeles",
        "is_trial_period": "false"
      }
    ]
  }
}
```
If the transactionId is in the response, then it's a valid transaction, we then insert a record into the transaction table, and tell client it's okay, then, client can clear the saved transaction id.

If there's something wrong with the server. The client should provide a retry mechanism to verify the saved transaction.

