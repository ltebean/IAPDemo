## Server side

First we need a table to store all the product info, the schema is:
```
id | product_id | title | description | coins | enabled | time_created | time_updated
```

* product_id: the iap's id registered in itunesconnect
* title: the product's title
* description: the product's description
* coins: the corresponding coins that will be given to the user 
