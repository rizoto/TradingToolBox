//
//  Trade.swift
//  BasicBox
//
//  Created by Lubor Kolacny on 2/5/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import Foundation

enum TradeState {
    case open
    case closed
}

struct Trade {
    let instrument: String
    let units: Double // + long; - short
    let price: Double
    let openTime: Date
    var closeTime: Date?
    var closePrice: Double?
    var state: TradeState
}
