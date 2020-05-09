//
//  StrategyTests.swift
//  BasicBoxTests
//
//  Created by Lubor Kolacny on 6/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import XCTest

@testable import TradingToolBox

class StrategyTests: XCTestCase {

    func testStrategy() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        let aud_usd = String("AUD_USD        ".prefix(10))
        let f1 = FlatPrice(instrument: aud_usd, time: 1.0, tradeable: true, bid_ask: true, price: 2.0, liquidity: 1)
        let f2 = FlatPrice(instrument: aud_usd, time: 2.0, tradeable: true, bid_ask: true, price: 1.0, liquidity: 1)
        let cancellable = [f1,f2].publisher.mapError { error -> Error in
            error
        }.eraseToAnyPublisher()
        let strategy = BasicStrategy4UnitTest(instrument: aud_usd, endOf: {
            expectation.fulfill()
        })
        let trader = Trader(account: Account(hedgingEnabled: true), ticks: cancellable)
        XCTAssert(trader.account.marketOrdersCount == 0)
        trader.runStrategy(strategy: strategy)
        wait(for: [expectation], timeout: 1)
        XCTAssert(trader.account.marketOrdersCount == 2)
    }
    
    func testScalpingStrategy() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        let aud_usd = String("AUD_USD        ".prefix(10))
        let cancellable = TickCache().eraseToAnyPublisher()
        let trader = Trader(account: Account(hedgingEnabled: true), ticks: cancellable)
        let strategy = ScalpingStrategy(instrument: aud_usd, endOf: {
            expectation.fulfill()
        })
        trader.runStrategy(strategy: strategy)
        wait(for: [expectation], timeout: 60)
    }
}
