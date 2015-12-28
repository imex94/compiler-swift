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

func ==(a: Regex, b: Regex) -> Bool {
    switch (a, b) {
    case (.NULL, .NULL): return true
    case (.EMPTY, .EMPTY): return true
    case (.CHAR(let c1), .CHAR(let c2)) where c1 == c2: return true
    case (.ALT(let x, let y), .ALT(let z, let v)) where x == z && y == v: return true
    case (.SEQ(let x, let y), .SEQ(let z, let v)) where x == z && y == v: return true
    case (.STAR(let x), .STAR(let y)) where x == y: return true
    case (.NTIMES(let x, let y), .NTIMES(let z, let v)) where x == z && y == v: return true
    case (.NOT(let x), .NOT(let y)) where x == y: return true
    case (.RECORD(let x, let y), .RECORD(let z, let v)) where x == z && y == v: return true
    default: return false
    }
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
            return ders(Array(rest), RegExp.simp(der(c, r)))
        }
    }
    
    class func matches(r: Regex, s: String) -> Bool {
        return nullable(ders(Array(s.characters), r))
    }
    
    class func simp(r: Regex) -> Regex {
        switch r {
        case .ALT(let r1, let r2):
            switch (simp(r1), simp(r2)) {
            case (.NULL, let re2): return re2
            case (let re1, .NULL): return re1
            case (let re1, let re2): return re1 == r2 ? re1 : .ALT(re1, re2)
            }
        case .SEQ(let r1, let r2):
            switch (simp(r1), simp(r2)) {
            case (.NULL, _): return .NULL
            case (_, .NULL): return .NULL
            case (.EMPTY, let re2): return re2
            case (let re1, .EMPTY): return re1
            case (let re1, let re2): return .SEQ(re1, re2)
            }
        case .NTIMES(let re1, let n): return .NTIMES(simp(re1), n)
        default: return r
        }
    }
}