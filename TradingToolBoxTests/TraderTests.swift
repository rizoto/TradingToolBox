//
//  TraderTests.swift
//  BasicBoxTests
//
//  Created by Lubor Kolacny on 2/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import XCTest
@testable import TradingToolBox

class TraderTests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testTrader() throws {
        let trader = Trader(account: Account(hedgingEnabled: true))
        _ = trader.account.createMarketOrderRequest(instrument: "A", units: 1, price: 1)
        XCTAssert(trader.account.marketOrdersCount > 0)
    }
    

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
