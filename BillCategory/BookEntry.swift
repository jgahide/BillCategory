//
//  BillStatement.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 18-02-26.
//  Copyright © 2018 Jerome GAHIDE. All rights reserved.
//

import Foundation

class BookEntry {
    private let billParts : Array<Substring>

    public var bill : Bill? = nil
    public var store : Store? = nil
    
    init(billStatementData: String) {
        self.billParts = billStatementData.split(separator: ",")
        
        if self.isValidStatement() {
            let date:String = self.billParts[0].trimmingCharacters(in:.whitespacesAndNewlines)
            let amount:String = self.billParts[2].trimmingCharacters(in:.whitespacesAndNewlines)
            
            self.store = Store(name:self.readStoreShortname(), fullName:String(self.billParts[1]))
            self.bill = Bill(date:date, amount: Float(amount)!, store: nil )
            self.bill?.store = self.store
        }
    }
    
     private func readStoreShortname() -> String {
        let longStoreName = String(self.billParts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        var shortStoreName = longStoreName
        
        let words = longStoreName.components(separatedBy: " ")
        if words.count > 3 {
            let firstWords = words[0...2] // keep the 3 first words
            shortStoreName = firstWords.joined(separator: " ")
        }
        
        return shortStoreName
    }
    
    func isValidStatement() -> Bool {
        return self.billParts.count >= 2
    }
        
    func categoryName() -> String? {
        if self.billParts.count > 3 {
            return String(self.billParts[3])
        }
        return nil
    }
}



