//
//  NumberPadType.swift
//  KocesICIOS
//
//  Created by ChangTae Kim on 12/24/24.
//

import Foundation

public enum NumberPadStyle {
    case square
    case circle
}

public enum NumberKey: Int {
    case key0 = 0, key1 = 1, key2, key3, key4, key5, key6, key7, key8, key9
    case custom = 99, delete = -1, empty = -2, clear = -3, key00 = -4, key010 = -5, keyok = -6
    
    func value() -> String? {
        if self.rawValue >= 0 && self.rawValue <= 9 {
            return "\(self.rawValue)"
        } else if self.rawValue == 99 {
            return nil
        } else if self.rawValue == -3 {
            return "지움"
        } else if self.rawValue == -4 {
            return "00"
        } else if self.rawValue == -5 {
            return "010"
        } else if self.rawValue == -6 {
            return "입력"
        } else {
            return nil
        }
    }
}

public enum NumberClearKeyPosition {
    case left, right
}
