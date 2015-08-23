//
//  ViewController.swift
//  RxBrightFutures
//
//  Created by Junior B. on 23/08/15.
//  Copyright © 2015 SideEffects.xyz. All rights reserved.
//

import UIKit
import RxSwift
import BrightFutures
import Result

class ViewController: UIViewController {

    let sourceStringURL = "http://api.fixer.io/latest?base=EUR&symbols=USD"
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var convertBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Actions
    @IBAction func convertPressed(sender: UIButton) {
        let stringURL = "http://api.fixer.io/latest?base=CHF&symbols=USD"
        
        let url = NSURL(string: stringURL)!
        let request = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let networkPromise = Promise<NSData, NSError>()
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) in
        
            if let e = error {
                networkPromise.tryFailure(e)
            } else {
                if let d = data {
                    networkPromise.trySuccess(d)
                } else {
                    networkPromise.tryFailure(NSError(domain: "xyz.sideeffects", code: -1, userInfo: nil))
                }
            }
        
        }
        
        networkPromise.future.flatMap() { value in
            return self.deserializeData(value)
        }.rx_observable().subscribeNext() { json in
            self.toTextField.text = self.processData(json)
        }
    
        task.resume()
    
    }

    // MARK: - Functions
    
    func displayError(e: NSError) {
        let alert = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deserializeData(data: NSData) -> Result<Dictionary<String, AnyObject>, NSError> {
        do {
            let dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String, AnyObject>
            return Result(value: dict)
        } catch (let e as NSError) {
            return Result(error: e)
        }
    }

    func processData(dict: Dictionary<String, AnyObject>) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        let valDict = dict["rates"] as! Dictionary<String, AnyObject>
        let value = valDict["USD"] as? Float
        let fromValue = NSNumberFormatter().numberFromString(self.fromTextField.text!)?.floatValue
        
        if let v = value, let fv = fromValue {
            return formatter.stringFromNumber(v*fv)!
        }
        
        return "invalid input"
    }



}

