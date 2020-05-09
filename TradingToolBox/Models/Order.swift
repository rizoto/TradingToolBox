//
//  Order.swift
//  BasicBox
//
//  Created by Lubor Kolacny on 2/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import Foundation

enum OrderType {
    case market
    case limit
}

enum OrderState {
    case pending
    case filled
}

struct Order {
    let instrument: String
    let units: Double
    let requestPrice: Double
    let orderType: OrderType
    let openTime: Date
    var orderState: OrderState
    let requestPriceProfit: Double
    let requestStopLoss: Double
}

