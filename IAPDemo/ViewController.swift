//
//  ViewController.swift
//  IAPDemo
//
//  Created by leo on 16/10/10.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SwiftyStoreKit
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

        SwiftyStoreKit.retrieveProductsInfo(productIds) { result in
            let products = result.retrievedProducts
            guard products.count > 0 else {
                SVProgressHUD.showError(withStatus: "Failed to find product")
                return
            }
            SVProgressHUD.dismiss()
            
            self.products = products.sorted(by: { p1, p2 -> Bool in
                return p1.price.compare(p2.price) == .orderedAscending
            })
            self.tableView.reloadData()
            
        }
    }

    func buy(product: SKProduct) {
        SVProgressHUD.show()
        SwiftyStoreKit.purchaseProduct(product.productIdentifier) { [weak self] result in
            switch result {
            case .success(_):
                SVProgressHUD.showSuccess(withStatus: "Success")
                self?.verifyTransaction()
            case .error(_):
                SVProgressHUD.showError(withStatus: "Error")
            }
        }
    }
    
    func verifyTransaction() {
        let url = Bundle.main.appStoreReceiptURL!
        let receipt = try! Data(contentsOf: url).base64EncodedString()
        // send this string to the server, let the server verify it
        // https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html
        
        // the server can get the transaction id and product id from the response by apple
        // then the server gives the user coins
        
        // server should also check whether the transction id is duplicated to proctect against fake request
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

