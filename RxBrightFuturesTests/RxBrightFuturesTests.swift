//
//  RxBrightFuturesTests.swift
//  RxBrightFuturesTests
//
//  Created by Junior B. on 23/08/15.
//  Copyright © 2015 SideEffects.xyz. All rights reserved.
//

import BrightFutures
import Foundation
import Result
import RxSwift
import RxTest
import XCTest

@testable import RxBrightFutures

class RxBrightFuturesTests: XCTestCase {
    let bag = DisposeBag()

    func testCompletedRxFuture() {
        let exp = self.expectation(description: #function)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Int.self)

        Future<Int, NoError>(value: 2)
            .rx_observable()
            .do(onError: { error in
                XCTFail("\(exp.description): Should not error here - got \(error)")
            }, onCompleted: {
                exp.fulfill()
            })
            .subscribe(observer)
            .addDisposableTo(bag)

        scheduler.start()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual(observer.events.count, 2)
            XCTAssertEqual(observer.events[0].value.element, 2)
            XCTAssertTrue(observer.events[1].value.isStopEvent)
            XCTAssertNil(observer.events[1].value.error)
        }
    }

    func testCompletedVoidRxFuture() {
        let exp = self.expectation(description: #function)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Void.self)

        Future<Void, NoError>(value: ())
            .rx_observable()
            .do(onError: { error in
                XCTFail("\(exp.description): Should not error here - got \(error)")
            }, onCompleted: {
                exp.fulfill()
            })
            .subscribe(observer)
            .addDisposableTo(bag)

        scheduler.start()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual(observer.events.count, 2)
            XCTAssertNotNil(observer.events[0].value.element)
            XCTAssertTrue(observer.events[1].value.isStopEvent)
            XCTAssertNil(observer.events[1].value.error)
        }
    }

    func testFailedRxFuture() {
        let exp = self.expectation(description: #function)
        let rxError = NSError(domain: "test", code: 0, userInfo: nil)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Void.self)

        Future<Void, NSError>(error: rxError)
            .rx_observable()
            .do(onError: { _ in
                exp.fulfill()
            }, onCompleted: {
                XCTFail("\(exp.description): Should not complete here")
            })
            .subscribe(observer)
            .addDisposableTo(bag)

        scheduler.start()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual(observer.events.count, 1)
            XCTAssertEqual(observer.events[0].value.error as? NSError, rxError)
            XCTAssertTrue(observer.events[0].value.isStopEvent)
            XCTAssertNil(observer.events[0].value.element)
        }
    }

    func testAsVoidRxFuture() {
        let exp = self.expectation(description: #function)
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Void.self)

        Future<Int, NoError>(value: 2)
            .asVoid()
            .rx_observable()
            .do(onError: { error in
                XCTFail("\(exp.description): Should not error here - got \(error)")
            }, onCompleted: {
                exp.fulfill()
            })
            .subscribe(observer)
            .addDisposableTo(bag)

        scheduler.start()

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual(observer.events.count, 2)
            XCTAssertNotNil(observer.events[0].value.element)
            XCTAssertTrue(observer.events[1].value.isStopEvent)
            XCTAssertNil(observer.events[1].value.error)
        }
    }
}
