//
//  RxBrightFutures.swift
//  RxBrightFutures
//
//  Created by Junior B. on 23/08/15.
//  Copyright © 2015 SideEffects.xyz. All rights reserved.
//

import RxSwift
import BrightFutures

extension Future {

    /**
    Creates and `Observable<T>` from a `Future<T>`
    
    - returns: An `Observable` of type `T`
    */
    func rx_observable() -> Observable<T> {
        return create() { observer in
            self.onComplete() { value in
                switch(value) {
                case .Success(let v):
                    sendNext(observer, v)
                    sendCompleted(observer)
                case .Failure(let e):
                    sendError(observer, e)
                }
            }
            return AnonymousDisposable {}
        }
    }
    
}

extension Promise {
    
    /**
    Creates and `Observable<T>` from a `Promise<T>`
    
    - returns: An `Observable` of type `T`
    */
    func rx_observable() -> Observable<T> {
        return create() { observer in
            self.future.onComplete() { value in
                switch(value) {
                case .Success(let v):
                    sendNext(observer, v)
                    sendCompleted(observer)
                case .Failure(let e):
                    sendError(observer, e)
                }
            }
            return AnonymousDisposable {}
        }
    }
}