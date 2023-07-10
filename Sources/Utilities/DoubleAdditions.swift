import Foundation

extension Double {
    func prettyFractionFormatted() -> String {
        let (integral, fractional) = modf(self)
        guard let symbol = Character(fraction: fractional) else { return formatted() }
        guard !integral.isZero else { return "\(symbol)" }
        return "\(integral.formatted())\(symbol)"
    }
}
