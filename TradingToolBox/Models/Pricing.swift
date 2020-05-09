
import Foundation
public struct FlatPrice {
    let instrument: String
    let time: Double
    let tradeable: Bool
    let bid_ask: Bool //Bid=false
    let price: Double
    let liquidity: Int
}

struct Price: Decodable {
    let type: String
    let time: String
    let bids:Array<BidAsk>
    let asks:Array<BidAsk>
    struct BidAsk: Decodable {
        let price: String
        let liquidity: Int
    }
    let closeoutBid: String
    let closeoutAsk: String
    let status: String
    let tradeable: Bool
    let instrument: String
}

class OandaDateFormater: ISO8601DateFormatter {
    override init() {
        super.init()
        self.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone, .withFractionalSeconds]
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension String {
    static let dateFormatter = OandaDateFormater()
    var toDate: Date {
        return String.dateFormatter.date(from: self)!
    }
}

extension Date {
    var toString: String {
        let GMT = TimeZone(abbreviation: "GMT")
        let options: ISO8601DateFormatter.Options = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone, .withFractionalSeconds]
        return ISO8601DateFormatter.string(from: self, timeZone: GMT!, formatOptions: options)
    }
}
