//
//  BillStatement.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 18-02-26.
//  Copyright © 2018 Jerome GAHIDE. All rights reserved.
//

import Foundation

class BillStatementReader {
    private let billParts : Array<Substring>
    
    var bill : Bill?
    var storeName : String?
    
    init(billStatementData: String) {
        self.billParts = billStatementData.split(separator: ",")
        
        if self.isValidStatement() {
            self.bill = Bill(date:String(self.billParts[0]), amount: Float(self.billParts[2])!)
            self.storeName = self.readStoreName()
        } else {
            self.bill = nil
            self.storeName = nil
        }

    }
    
    
     private func readStoreName() -> String {
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
    
//    func hasACategory() -> Bool {
//        return self.billParts.count > 3
//    }
    
    func categoryName() -> String? {
        if self.billParts.count > 3 {
            return String(self.billParts[3])
        }
        return nil
    }

}



