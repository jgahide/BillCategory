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
    func readStoreFullName() -> String
    func readTransactionDate() -> String
    func readAmount() -> Float
    
    func categoryName() -> String?
}

extension BookEntry {
    func parseEntry() -> Void {
        if self.isValidStatement() {
            self.bill = Bill(date:self.readTransactionDate(), amount: self.readAmount(), store: nil )
            let store = Store(name:self.readStoreShortname(), fullName:self.readStoreFullName())
            self.bill?.store = store
        }
    }
    
    static func interpretDoubleQuote(inStatementData data:String) -> String {
        let regex = try! NSRegularExpression(pattern:"\"(.*)\"")
        if let match = regex.firstMatch(
            in: data, range:NSMakeRange(0,data.utf16.count)) {
            var interpretedBillStatementData = data
            let amount = (data as NSString).substring(with: match.range(at:1))
            let amountCorrected = amount.replacingOccurrences(of: ",", with: ".")
            interpretedBillStatementData = interpretedBillStatementData.replacingOccurrences(of: "\""+amount+"\"", with: amountCorrected)
            return interpretedBillStatementData
        }
        return data
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
    
    internal func readStoreFullName() -> String {
        return String(self.billParts[1])
    }
    
    internal func readTransactionDate() -> String {
        return self.billParts[0].trimmingCharacters(in:.whitespacesAndNewlines)
    }
    
    internal func readAmount() -> Float {
        let amount:String = self.billParts[2].trimmingCharacters(in:.whitespacesAndNewlines)
        return abs(Float(amount)!) * -1
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
        let interpretedData = MastercardBookEntry.interpretDoubleQuote(inStatementData: billStatementData)
        self.billParts = interpretedData.split(separator: ",")
        self.parseEntry()
    }
    
    func isValidStatement() -> Bool {
        return
            self.billParts.count == 4 &&
            self.readStoreFullName().range(of:"PAYMENT - THANK YOU" ) == nil
    }
    
    func readStoreShortname() -> String {
        let fullname = self.readStoreFullName()
        let words = fullname.components(separatedBy: " ")
        var shortStoreName = self.readStoreFullName()
        if words.count > 2 {
            let firstWords = words[0...2] // keep the 3 first words
            shortStoreName = firstWords.joined(separator: " ")
        }
        
        return shortStoreName
    }
    
    func readStoreFullName() -> String {
        // Mastercard bills description are made of column "  "
        // The name is contained in the first column.
        // ex : TOASTEUR LAURIER       MONTREAL      QC  CAN
        let columns = self.billParts[2].components(separatedBy: "  ")
        return columns[0].trimmingCharacters(in:.whitespacesAndNewlines)
    }
    
    func readTransactionDate() -> String {
        return String(self.billParts[0]).trimmingCharacters(in:.whitespacesAndNewlines)
    }
    
    func readAmount() -> Float {
        let amount:String = self.billParts[3].trimmingCharacters(in:.whitespacesAndNewlines)
        return abs(Float(amount)!) * -1
    }
    
    func categoryName() -> String? {
        return nil
    }

}

class ChequeAccountBookEntry : BookEntry {
    var bill: Bill?
    
    // local properties
    let billParts : Array<Substring>
    
    // ex : 12 Mars 2018,ACHT PMT DIRECT SUPER DEPANNEUR BON AI #0001482014 APOF23837,"-3,75"
    
    init(billStatementData: String) {
        let interpretedData = ChequeAccountBookEntry.interpretDoubleQuote(inStatementData: billStatementData)
        self.billParts = interpretedData.split(separator: ",")
        self.parseEntry()
    }
    
    func isValidStatement() -> Bool {
        return
            self.billParts.count == 3 &&
            self.readStoreFullName().range(of:"HSBC MASTERCARD" ) == nil // On omet les remboursement a la carte Mastercard
    }
    
    func readStoreShortname() -> String {
        var storeShortName : String = String(self.billParts[1])
        if let range = storeShortName.range(of: "#") {
            storeShortName = storeShortName.substring(to: range.lowerBound)
        }
        if let range = storeShortName.range(of: "ACHT PMT DIRECT") {
            storeShortName = storeShortName.substring(from: range.upperBound)
        }
        return storeShortName.trimmingCharacters(in:.whitespacesAndNewlines)
    }
    
    func readStoreFullName() -> String {
        return self.readStoreShortname()
    }
    
    func readTransactionDate() -> String {
        return String(self.billParts[0])
    }
    
    func readAmount() -> Float {
        var amount:String = self.billParts[2].trimmingCharacters(in:.whitespacesAndNewlines)
        amount = amount.replacingOccurrences(of:" ", with:"")
        return abs(Float(amount)!) * -1
    }
    
    func categoryName() -> String? {
        return nil
    }
    
    
}
