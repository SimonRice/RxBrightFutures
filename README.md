# RxBrightFutures

RxBrightFutures is a tiny wrapper around [BrightFutures](https://github.com/Thomvis/BrightFutures) that allows transforming promises and futures into observables or subjects using a single function `rx_observable` or `rx_subject`.

## Example

There's a project as example in the repository, but the basic is shown in the following snipped:

```swift
let stringURL = "..."        
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
            networkPromise.tryFailure(NSError(domain: "Data error", code: -1, userInfo: nil))
        }
    }

}

networkPromise.future
	.flatMap() { value in
    	return self.deserializeData(value)
	}
	.rx_observable()
	.subscribeNext() { json in
    	self.toTextField.text = self.processData(json)
	}

task.resume()
```

### Contributions

Contributions are welcomed in the `develop` repository. Any pull-request to the `master` branch will be rejected.

## LICENSE

This project is released under [MIT License](LICENSE).