//
//  Trader.swift
//  BasicBox
//
//  Created by Lubor Kolacny on 2/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import Foundation
import Combine

public protocol Strategy {
    var instrument: String {get set}
    var endOf: () -> Void {get set}
    func tick(price: FlatPrice, account: Account) -> Account
}

public protocol PublicTrading {
    func runStrategy(strategy: Strategy)
}

protocol Trading {
    func createMarketOrderRequest(instrument: String, units: Double, price: Double) -> Bool
}

public class Trader {
    internal var account: Account
    internal var set = Set<AnyCancellable>()
    internal var ticks: AnyPublisher <FlatPrice, Error>
    public init(account: Account, ticks: AnyPublisher <FlatPrice, Error> = Empty<FlatPrice, Error>().eraseToAnyPublisher()) {
        self.account = account
        self.ticks = ticks
    }
}

struct BasicStrategy4UnitTest: Strategy {
    var instrument: String
    var endOf: () -> Void
    
    func tick(price: FlatPrice, account: Account) -> Account {
        _ = account.createMarketOrderRequest(instrument: price.instrument, units: 1, price: Double(price.price))
        return account
    }
}

extension Trader: Trading {
    func createMarketOrderRequest(instrument: String, units: Double, price: Double) -> Bool {
        account.createMarketOrderRequest(instrument: instrument, units: units, price: price)
    }
    
    public func runStrategy(strategy: Strategy) {
        let sub = ticks
            .filter { price -> Bool in
                price.instrument == strategy.instrument && price.tradeable }
            .reduce(account, { (account, price) -> Account in
                strategy.tick(price: price, account: account)
            }).sink(receiveCompletion: {completion in
                switch completion {
                case .failure:
                    break
                case .finished:
                    strategy.endOf()
                }
            }) { account in
                self.account = account}
        sub.store(in: &set)
        //replaceError(with: account).assign(to: \Trader.account, on: self)
    }
}
