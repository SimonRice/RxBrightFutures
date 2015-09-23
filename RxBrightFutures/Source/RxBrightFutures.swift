//
//  RxBrightFutures.swift
//  RxBrightFutures
//
//  Created by Junior B. on 23/08/15.
//  Copyright © 2015 SideEffects.xyz. All rights reserved.
//

import RxSwift
import BrightFutures
import Result

extension Future {

    /**
    Creates an `Observable<T>` from a `Future<T>`.
    
    - returns: An `Observable` of type `T`
    */
    func rx_observable() -> Observable<T> {
        return create() { observer in
            self.onComplete() { value in
                switch(value) {
                case .Success(let v):
                    observer.on(.Next(v))
                    observer.on(.Completed)
                case .Failure(let e):
                    observer.on(.Error(e))
                }
            }
            return AnonymousDisposable {}
        }
    }
    
}

extension Promise {
    
    /**
    Creates an `Observable<T>` from a `Promise<T>`.
    
    - returns: An `Observable` of type `T`
    */
    func rx_observable() -> Observable<T> {
        return create() { observer in
            self.future.onComplete() { value in
                switch(value) {
                case .Success(let v):
                    observer.on(.Next(v))
                    observer.on(.Completed)
                case .Failure(let e):
                    observer.on(.Error(e))
                }
            }
            return AnonymousDisposable {}
        }
    }
    
    /**
    Creates a bidirectional `Subject<T>` from a `Promise<T>`.
    Completing the promise will send the completion message to the subject,
    viceversa completing the promise will complete the subject.
    
    - returns: A `Subject` of type `T`
    */
    func rx_subject() -> BehaviorSubject<T?> {
        let subject = BehaviorSubject<T?>(value: nil)
        
        self.future.onComplete() { value in
            switch(value) {
            case .Success(let v):
                subject.on(.Next(v))
                subject.on(.Completed)
            case .Failure(let e):
                subject.on(.Error(e))
            }
        }
        
        subject.subscribeNext() { [weak self] v in
            if let uv = v {
                self?.trySuccess(uv)
            }
        }
        
        subject.subscribeError() { [weak self] e in
            self?.tryFailure(e as! E)
            return
        }
        
        return subject
    }
}