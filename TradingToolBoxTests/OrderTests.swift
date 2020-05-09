//
//  OrderTests.swift
//  BasicBoxTests
//
//  Created by Lubor Kolacny on 6/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import XCTest
@testable import TradingToolBox

class OrderTests: XCTestCase {

    func testFillingMarketOrderLong() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createMarketOrderRequest(instrument: "AAA", units: 1.0, price: 1.0)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 1.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
    }

    func testFillingMarketOrderShort() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createMarketOrderRequest(instrument: "AAA", units: -1.0, price: 1.0)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 1.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
    }
    
    func testFillingLimitOrderLongNoHedging() throws {
        let account = Account(hedgingEnabled: false)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: 1.0, price: 1.5)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 2.0, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 2.0, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 1.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 1.0)
    }
    
    func testFillingLimitOrderShortNoHedging() throws {
        let account = Account(hedgingEnabled: false)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: -1.0, price: 3.0)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 2.0, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 2.0, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 3.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 3.0)
    }
    
    func testFillingLimitOrderLongHedgingV1() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: 1.0, price: 5.0)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 2.0, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 6.0, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 5.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 5.0)
    }
    
    func testFillingLimitOrderLongHedgingV2() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: 1.0, price: 5.0)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 2.0, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 4.9, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 5.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 5.0)
    }
    
    func testFillingLimitOrderLongHedgingV3() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: 1.0, price: 5.0)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 2.0, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 4.9, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 5.1, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 5.1)
    }
    
    func testFillingLimitOrderShortHedgingV1() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: -1.0, price: 5.0)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 2.0, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 6.0, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 5.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 5.0)
    }
    
    func testFillingLimitOrderShortHedgingV2() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: -1.0, price: 5.0)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 5.5, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 6.0, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 5.0, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 5.0)
    }
    
    func testFillingLimitOrderShortHedgingV3() throws {
        let account = Account(hedgingEnabled: true)
        _ = account.createLimitOrderRequest(instrument: "AAA", units: -1.0, price: 5.0)
        let bid = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 5.5, liquidity: 1)
        let ask = FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: true, price: 6.0, liquidity: 1)
        account.setBidAsk(bid: bid, ask: ask)
        account.processTick(price: FlatPrice(instrument: "AAA", time: 0, tradeable: true, bid_ask: false, price: 4.9, liquidity: 1))
        XCTAssert(account.orders.first?.orderState == .filled)
        XCTAssert(account.openPositions.count > 0)
        XCTAssert(account.openPositions.first?.price == 4.9)
    }
}
