//
//  AccountTests.swift
//  BasicBoxTests
//
//  Created by Lubor Kolacny on 6/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import XCTest
@testable import TradingToolBox


class AccountTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAccountMarketOrder() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createMarketOrderRequest(instrument: "AAA", units: 1, price: 1)
        XCTAssert(account.marketOrdersCount == 1)
        XCTAssert(account.limitOrdersCount == 0)
    }
    
   func testAccountLimitOrder() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: 1, price: 1)
        XCTAssert(account.limitOrdersCount == 1)
        XCTAssert(account.marketOrdersCount == 0)
    }
    
    func testShouldCloseLongFromMarketOrder() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createMarketOrderRequest(instrument: "AAA", units: 1.0, price: 1.0)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 1.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.pl == 0.0)
        account.shouldCloseLongPositions = true
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 2.0, liquidity: 1))
        XCTAssert(account.pl != 0.0)
        XCTAssert(account.openPositions.first?.state == .closed)
    }
    
    func testShouldCloseShortFromMarketOrder() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createMarketOrderRequest(instrument: "AAA", units: -1.0, price: 1.0)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 1.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.pl == 0.0)
        account.shouldCloseShortPositions = true
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 2.0, liquidity: 1))
        XCTAssert(account.pl != 0.0)
        XCTAssert(account.openPositions.first?.state == .closed)
    }
    
    func testShouldCloseShortLimitOrderShortHedgingV3() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: -1.0, price: 5.0)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 5.5, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 6.0, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 4.9, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 4.9)
        XCTAssert(account.pl == 0.0)
        account.shouldCloseShortPositions = true
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 2.0, liquidity: 1))
        XCTAssert(account.pl != 0.0)
        XCTAssert(account.openPositions.first?.state == .closed)
    }

}
