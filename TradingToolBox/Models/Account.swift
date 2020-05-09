//
//  Account.swift
//  BasicBox
//
//  Created by Lubor Kolacny on 1/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import Foundation
//import Combine

protocol AccountManager {
    func createMarketOrderRequest(instrument: String, units: Double, price: Double) -> Bool
    func createLimitOrderRequest(instrument: String, units: Double, price: Double) -> Bool
    func processTick(price: FlatPrice) -> Void
//    func closePositionsRequest()
}

public class Account {
    let hedgingEnabled: Bool
    private(set) var openPositions = [Trade]()
    private(set) var orders = [Order]()
    
    private(set) var lastBid: FlatPrice!
    private(set) var lastAsk: FlatPrice!
    
    var shouldCloseLongPositions = false
    var shouldCloseShortPositions = false
    
    private(set) var pl = 0.0 // Profit/Loss
    
    public init(hedgingEnabled: Bool) {
        self.hedgingEnabled = hedgingEnabled
    }
}

extension Account: AccountManager {
    //MARK: Process orders
    func createMarketOrderRequest(instrument: String, units: Double, price: Double) -> Bool {
        orders.append(Order(instrument: instrument, units: units, requestPrice: price, orderType: .market, openTime: Date(), orderState: .pending))
        return true
    }
    func createLimitOrderRequest(instrument: String, units: Double, price: Double) -> Bool {
        orders.append(Order(instrument: instrument, units: units, requestPrice: price, orderType: .limit, openTime: Date(), orderState: .pending))
        return true
    }
    var marketOrdersCount: Int {
        orders.filter({ o -> Bool in
            o.orderType == .market
            }).count
    }
    
    var limitOrdersCount: Int {
        orders.filter({ o -> Bool in
            o.orderType == .limit
            }).count
    }
    
    
    //MARK: Process Tick
    func processTick(price: FlatPrice) {
        // TODO: check margin call
        // check market & limit orders
        if orders.count > 0 {
            for index in 0...orders.count-1 {
                if orders[index].orderState != .filled {
                    _ = fillOrder(order: &orders[index], price: price)
                }
            }
        }
        // if requested, close positions
        closePositionsRequest(price: price)
        
        // set previous tick
        if price.bid_ask {
            lastAsk = price
        } else {
            lastBid = price
        }
    }
    
    //MARK: Test Helpers
    func setBidAsk(bid: FlatPrice, ask: FlatPrice) {
        lastAsk = ask
        lastBid = bid
    }
}

//MARK: Internal logic
private extension Account {
    func fillOrder(order: inout Order, price: FlatPrice) -> Bool {
        assert(order.orderState == .pending
            && order.instrument == price.instrument)
        // create a trade
        if order.orderType == .market {
            // fill the order with the first tick
            if (price.bid_ask && order.units > 0) || (!price.bid_ask && order.units < 0) {
                // buy (long) || sell (short)
                openPositions.append(Trade(instrument: order.instrument, units: order.units, price: price.price, openTime: Date(), state: .open))
                // change status to filled
                order.orderState = .filled
            }
        }
        if order.orderType == .limit {
            // assumption: hedging enabled, must cross the price from either direction
            if fillLimitOrderCondition(price: price, order: order) {
                openPositions.append(Trade(instrument: order.instrument, units: order.units, price: price.price, openTime: Date(), state: .open))
                // change status to filled
                order.orderState = .filled
            }
        }
        return true
    }
    
    func fillLimitOrderCondition(price: FlatPrice, order: Order) -> Bool {
        // buy (long)
        return (price.bid_ask && order.units > 0 && price.price <= order.requestPrice && order.requestPrice < lastAsk.price) ||
        // sell (short)
        (!price.bid_ask && order.units < 0 && price.price >= order.requestPrice && order.requestPrice > lastBid.price) ||
        // buy (long)
        (hedgingEnabled && price.bid_ask && order.units > 0 && price.price >= order.requestPrice && order.requestPrice > lastAsk.price) ||
        // sell (short)
        (hedgingEnabled && !price.bid_ask && order.units < 0 && price.price <= order.requestPrice && order.requestPrice < lastBid.price)
    }
    
    //MARK: Close Positions
    func closePositionsRequest(price: FlatPrice) {
        // long closes with bid price
        if !price.bid_ask && shouldCloseLongPositions && openPositions.count > 0 {
            for index in 0...openPositions.count-1 {
                if openPositions[index].state == .open && openPositions[index].units > 0 {
                    openPositions[index].closeTime = Date()
                    openPositions[index].closePrice = price.price
                    openPositions[index].state = .closed
                    pl += (openPositions[index].units * (price.price - openPositions[index].price))
                }
            }
            shouldCloseLongPositions = false
        } else if price.bid_ask && shouldCloseShortPositions && openPositions.count > 0 {
            for index in 0...openPositions.count-1 {
                if openPositions[index].state == .open && openPositions[index].units < 0 {
                    openPositions[index].closeTime = Date()
                    openPositions[index].closePrice = price.price
                    openPositions[index].state = .closed
                    pl += (openPositions[index].units * (price.price - openPositions[index].price))
                }
            }
            shouldCloseShortPositions = false
        }
    }
}
