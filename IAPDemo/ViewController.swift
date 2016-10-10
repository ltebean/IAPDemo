//
//  ViewController.swift
//  IAPDemo
//
//  Created by leo on 16/10/10.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import IAPHelper
import SVProgressHUD
import StoreKit

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var needsBuyProduct: ((_ product: SKProduct) ->())!

    var product: SKProduct! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        titleLabel.text = formatter.string(from: product.price)
    }
    
    @IBAction func buyButtonPressed(_ sender: AnyObject) {
        needsBuyProduct(product)
    }
}



class ViewController: UIViewController {

    let iapHelper = IAPShare.sharedHelper()!
    
    @IBOutlet weak var tableView: UITableView!
    var products: [SKProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch theses product ids from server
        let productIds = [
            "io.ltebean.iapdemo.iap1",
            "io.ltebean.iapdemo.iap2"
        ] as Set
        
        SVProgressHUD.show()
        iapHelper.iap = IAPHelper(productIdentifiers: productIds)
        
        iapHelper.iap.requestProducts(completion: { request, response in
            guard let products = response?.products, products.count > 0 else {
                SVProgressHUD.showError(withStatus: "Failed to find product")
                return
            }
            SVProgressHUD.dismiss()
    
            self.products = products.sorted(by: { p1, p2 -> Bool in
                return p1.price.compare(p2.price) == .orderedAscending
            })
            self.tableView.reloadData()
        })
    }

    func buy(product: SKProduct) {
        SVProgressHUD.show()
        iapHelper.iap.buyProduct(product, onCompletion: { [weak self] transaction in
            SVProgressHUD.showSuccess(withStatus: "Success")
            self?.savePendingTransaction(id: transaction!.transactionIdentifier!)
            self?.verifyPendingTransaction()
        })

    }
    
    func savePendingTransaction(id: String) {
        UserDefaults.standard.set(id, forKey: "transaction")
    }
    
    func getPendingTransaction() -> String? {
        return UserDefaults.standard.string(forKey: "transaction")
    }
    
    func clearPendingTransaction() {
        UserDefaults.standard.removeObject(forKey: "transaction")
    }
    
    func verifyPendingTransaction() {
        guard let transactionId = getPendingTransaction() else {
            return
        }
        let url = Bundle.main.appStoreReceiptURL!
        let receipt = try! Data(contentsOf: url).base64EncodedString()
        print("receipt: \(receipt)")
        
        let data = [
            "transaction": transactionId,
            "receipt": receipt
        ]
        // post the data to the server, let the server verify whether the transaction is valid
        
        // the server can get the transaction id and product id from the response by apple
        // then the server gives the user coins
        
        // server should also check whether the transction id is duplicated to proctect against fake request
        
        // if server returns success, clear the pending transaction
        // if server is down, present a ui to allow the user to retry, we just need to call verifyPendingTransaction again.
        
        clearPendingTransaction()
    }
    

}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductCell
        cell.product = products[indexPath.row]
        cell.needsBuyProduct = { [weak self] product in
            self?.buy(product: product)
        }
        return cell
    }
}

