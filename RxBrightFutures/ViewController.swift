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

    private let disposeBag = DisposeBag()
    private let sourceStringURL = "http://api.fixer.io/latest?base=EUR&symbols=USD"

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
    @IBAction func convertPressed(_ sender: UIButton) {
        let url = URL(string: sourceStringURL)!
        let request = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let networkPromise = Promise<Data, NSError>()

        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in

            if let e = error {
                networkPromise.tryFailure(e as NSError)
            } else {
                if let d = data {
                    networkPromise.trySuccess(d)
                } else {
                    networkPromise.tryFailure(NSError(domain: "xyz.sideeffects", code: -1, userInfo: nil))
                }
            }

        })

        networkPromise.future.flatMap() { value in
            return self.deserializeData(value)
        }.rx_observable().subscribe { event in
            if case .next(let json) = event {
                self.toTextField.text = self.processData(json)
            }
        }.addDisposableTo(disposeBag)

        task.resume()

    }

    // MARK: - Functions

    func displayError(_ e: NSError) {
        let alert = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }

    func deserializeData(_ data: Data) -> Result<Dictionary<String, Any>, NSError> {
        do {
            let dict = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String, Any>
            return Result(value: dict)
        } catch (let e as NSError) {
            return Result(error: e)
        }
    }

    func processData(_ dict: Dictionary<String, Any>) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let valDict = dict["rates"] as! Dictionary<String, AnyObject>
        let value = valDict["USD"] as? Float
        let fromValue = NumberFormatter().number(from: self.fromTextField.text!)?.floatValue

        if let v = value, let fv = fromValue {
            return formatter.string(from: NSNumber(value: v * fv))!
        }

        return "invalid input"
    }
}
