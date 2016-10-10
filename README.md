## Server side

First we need a table to store all the product info, the schema is:
```
id | product_id | title | description | coins | enabled | time_created | time_updated
```

* product_id: the iap's id registered in itunesconnect
* title: the product's title
* description: the product's description
* coins: the corresponding coins that will be given to the user 

Add we need a table to store all the transactions
```
id | transaction_id | product_id | user_id | time_created | time_updated
```
* transaction_id: the transaction id, we can get it from the iap receipt
* product_id: which product
* user_id: who bought the product

## Client side
