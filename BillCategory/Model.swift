//
//  BillStatement.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 17-11-15.
//  Copyright © 2017 Jerome GAHIDE. All rights reserved.
//

import Foundation

// pour pourvoir surcharger la description on implemente CustomStringConvertible
class Store : CustomStringConvertible {
    var name : String = "" // Beneficiaire
    var bills : Array<Bill> = []
    var category : Category?
    
    init(name: String) {
        self.name = name
    }
    
    var description: String {
        if let cat = self.category {
            return "Store: {\n  name: '\(self.name)'\n  \(cat)\n  bills: \(self.bills)\n}"
        } else {
            return "Store: {\n  name: '\(self.name)'\n  bills: \(self.bills)\n}"
        }
    }

}

struct Bill : CustomStringConvertible {
    let date : String
    let amount : Float

    var description: String {
        return "Bill date : \(self.date) amount : \(self.amount) "
    }
    
}

class Category : CustomStringConvertible {
    var name : String = "" // restaurant , epicerie ...
    var tags : Set<String> = []
    
    init(name: String, storeName:String) {
        self.name = name
        self.addTags(fromStoreName: storeName)
    }
    
    func addTags(fromStoreName:String) -> Void {
        let tags = fromStoreName.components(separatedBy: " ")
        let longTagNames = tags.filter{$0.count > 3} // keep only tag/word string that are longer than 3 chars.
        self.tags = self.tags.union(longTagNames)
    }
    
    var description: String {
        return "Category : \(self.name) tags : \(self.tags)"
    }

}
