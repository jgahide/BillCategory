//
//  BillStatement.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 18-02-26.
//  Copyright © 2018 Jerome GAHIDE. All rights reserved.
//

import Foundation

protocol BookEntry : class , CustomStringConvertible {
    var bill : Bill? { get set }
    
    func isValidStatement() -> Bool
    func readStoreShortname() -> String
    func readFullName() -> String
    func readDate() -> String
    func readAmount() -> Float
    
    func categoryName() -> String?
}

extension BookEntry {
    func parseEntry() -> Void {
        if self.isValidStatement() {
            self.bill = Bill(date:self.readDate(), amount: self.readAmount(), store: nil )
            let store = Store(name:self.readStoreShortname(), fullName:self.readFullName())
            self.bill?.store = store
        }
    }
    
    var description: String {
        return "" + (self.bill?.description)!
    }
}

class GreatBookEntry : BookEntry {
    // Protocol var implementation
    internal var bill : Bill? = nil
    
    // local properties
    let billParts : Array<Substring>

    
    init(billStatementData: String) {
        self.billParts = billStatementData.split(separator: ",")
        self.parseEntry()
    }
    
    
    func isValidStatement() -> Bool {
        return self.billParts.count >= 2
    }
    
    internal func readStoreShortname() -> String {
        let longStoreName = String(self.billParts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        var shortStoreName = longStoreName
        
        let words = longStoreName.components(separatedBy: " ")
        if words.count > 3 {
            let firstWords = words[0...2] // keep the 3 first words
            shortStoreName = firstWords.joined(separator: " ")
        }
        
        return shortStoreName
    }
    
    internal func readFullName() -> String {
        return String(self.billParts[1])
    }
    
    internal func readDate() -> String {
        return self.billParts[0].trimmingCharacters(in:.whitespacesAndNewlines)
    }
    
    internal func readAmount() -> Float {
        let amount:String = self.billParts[2].trimmingCharacters(in:.whitespacesAndNewlines)
        return Float(amount)!
    }
    
    
    func categoryName() -> String? {
        if self.billParts.count > 3 {
            return String(self.billParts[3]).trimmingCharacters(in:.whitespacesAndNewlines)
        }
        return nil
    }
}

class MastercardBookEntry : BookEntry {
    // Protocol var implementation
    internal var bill : Bill? = nil
    
    // local properties
    let billParts : Array<Substring>
    
    
    init(billStatementData: String) {
        self.billParts = billStatementData.split(separator: ",")
        self.parseEntry()
    }
    
    func isValidStatement() -> Bool {
        return true
    }
    
    func readStoreShortname() -> String {
        let words = self.billParts[2].components(separatedBy: " ")
        var shortStoreName = String(self.billParts[2])
        if words.count > 2 {
            let firstWords = words[0...1] // keep the 2 first words
            shortStoreName = firstWords.joined(separator: " ")
        }
        
        return shortStoreName
    }
    
    func readFullName() -> String {
        return String(self.billParts[2])
    }
    
    func readDate() -> String {
        return String(self.billParts[0])
    }
    
    func readAmount() -> Float {
        var amount:String = self.billParts[3].trimmingCharacters(in:.whitespacesAndNewlines)
        amount = amount.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
        return Float(amount)! * -1
    }
    
    func categoryName() -> String? {
        return nil
    }

}

