//
//  Regex.swift
//  SwiftCompiler
//
//  Created by Alex Telek on 27/12/2015.
//  Copyright © 2015 Alex Telek. All rights reserved.
//

import Cocoa

enum Regex {
    case NULL
    case EMPTY
    case CHAR(Character)
    indirect case ALT(Regex, Regex)
    indirect case SEQ(Regex, Regex)
    indirect case STAR(Regex)
    indirect case NTIMES(Regex, Int)
    indirect case NOT(Regex)
    indirect case RECORD(String, Regex)
}

class RegExp: NSObject {
    
    class func nullable(r: Regex) -> Bool {
        switch r {
        case .NULL: return false
        case .EMPTY: return true
        case .CHAR(_): return false
        case .ALT(let r1, let r2): return nullable(r1) || nullable(r2)
        case .SEQ(let r1, let r2): return nullable(r1) && nullable(r2)
        case .STAR(_): return true
        case .NTIMES(let r1, let n): return n == 0 ? true : nullable(r1)
        case .NOT(let r1): return !nullable(r1)
        case .RECORD(_, let r1): return nullable(r1)
        }
    }
    
    class func der(c: Character, _ r: Regex) -> Regex {
        switch r {
        case .NULL: return .NULL
        case .EMPTY: return .NULL
        case .CHAR(let d): return c == d ? .EMPTY : .NULL
        case .ALT(let r1, let r2): return .ALT(der(c, r1), der(c, r2))
        case .SEQ(let r1, let r2):
            if nullable(r1) {
                return .ALT(.SEQ(der(c, r1), r2), der(c, r2))
            } else {
                return .SEQ(der(c, r1), r2)
            }
        case .STAR(let r1): return .SEQ(der(c, r1), .STAR(r1))
        case .NTIMES(let r1, let n): return n == 0 ? .NULL : .SEQ(der(c, r1), .NTIMES(r1, n - 1))
        case .NOT(let r1): return .NOT(der(c, r1))
        case .RECORD(_, let r1): return der(c, r1)
        }
    }
    
    class func ders(s: Array<Character>, _ r: Regex) -> Regex {
        switch s.count {
        case 0: return r
            //TODO: Simplification
        default:
            let (c, rest) = (s.first!, s.dropFirst())
            return ders(Array(rest), der(c, r))
        }
    }
    
    class func matches(r: Regex, s: String) -> Bool {
        return nullable(ders(Array(s.characters), r))
    }
}
