//
//  RxBrightFuturesTests.swift
//  RxBrightFuturesTests
//
//  Created by Junior B. on 23/08/15.
//  Copyright © 2015 SideEffects.xyz. All rights reserved.
//

import BrightFutures
import Result
import RxBlocking
import RxTest
import XCTest

@testable import RxBrightFutures

class RxBrightFuturesTests: XCTestCase {
    func testFirstSingleValueFuture() {
        do {
            let result = try Future<Int, NoError>(value: 10)
                .rx_observable()
                .toBlocking()
                .first()!

            XCTAssertEqual(result, 10)
        } catch let error {
            XCTFail(String(describing: error))
        }
    }

    func testLastSingleValueFuture() {
        do {
            let result = try Future<Int, NoError>(value: 10)
                .rx_observable()
                .toBlocking()
                .last()!

            XCTAssertEqual(result, 10)
        } catch let error {
            XCTFail(String(describing: error))
        }
    }
}
