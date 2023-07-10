import Foundation

extension Character {
    
    init?(fraction: Double) {
        switch fraction {
        case 1/2:
            self = "½"
        case 1/3, 0.33:
            self = "⅓"
        case 2/3, 0.66:
            self = "⅔"
        case 1/4:
            self = "¼"
        case 3/4:
            self = "¾"
        case 1/5:
            self = "⅕"
        case 2/5:
            self = "⅖"
        case 3/5:
            self = "⅗"
        case 4/5:
            self = "⅘"
        case 1/6:
            self = "⅙"
        case 5/6:
            self = "⅚"
        case 1/7:
            self = "⅐"
        case 1/8:
            self = "⅛"
        case 3/8:
            self = "⅜"
        case 5/8:
            self = "⅝"
        case 7/8:
            self = "⅞"
        case 1/9:
            self = "⅑"
        case 1/10:
            self = "⅒"
        default:
            return nil
        }
    }
    
}
