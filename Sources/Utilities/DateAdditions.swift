import Foundation

extension FormatStyle where Self == Date.ISO8601FormatStyle {

    static var shortISODate: Date.ISO8601FormatStyle {
        var result = iso8601.year().month().day().dateSeparator(.omitted)
        result.timeZone = .current
        return result
    }

}
