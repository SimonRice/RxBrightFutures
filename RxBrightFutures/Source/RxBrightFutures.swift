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
        return Observable.create { observer in
            self.onComplete { value in
                switch value {
                case .success(let v):
                    observer.on(.next(v))
                    observer.on(.completed)
                case .failure(let e):
                    observer.on(.error(e))
                }
            }
            return Disposables.create()
        }
    }

}

extension Promise {

    /**
    Creates an `Observable<T>` from a `Promise<T>`.

    - returns: An `Observable` of type `T`
    */
    func rx_observable() -> Observable<T> {
        return Observable.create { observer in
            self.future.onComplete { value in
                switch value {
                case .success(let v):
                    observer.on(.next(v))
                    observer.on(.completed)
                case .failure(let e):
                    observer.on(.error(e))
                }
            }
            return Disposables.create()
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

        self.future.onComplete { value in
            switch value {
            case .success(let v):
                subject.on(.next(v))
                subject.on(.completed)
            case .failure(let e):
                subject.on(.error(e))
            }
        }

        let _ = subject.subscribe { [weak self] event in
            if case .next(let v) = event, let uv = v {
                self?.trySuccess(uv)
            } else if case .error(let e) = event {
                // swiftlint:disable:next force_cast
                self?.tryFailure(e as! E)
            }
            return
        }

        return subject
    }
}
