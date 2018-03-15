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
    var category : Category?
    
    init(name: String) {
        self.name = name.trimmingCharacters(in:.whitespacesAndNewlines)
    }
    
    var description: String {
        if let cat = self.category {
            return "Store: {\n  name: '\(self.name)'\n  catégory: \(cat)\n}"
        } else {
            return "Store: {\n  name: '\(self.name)'\n}"
        }
    }
    
    static func ==(lhs: Store, rhs: Store) -> Bool {
        return lhs.name == rhs.name
    }
}

struct Bill : CustomStringConvertible {
    let date : String
    let amount : Float
    var store : Store?
    
    var description: String {
        if let store = self.store {
            return "Bill date : \(self.date) amount : \(self.amount) store : \(store.name)\n"
        } else {
            return "Bill date : \(self.date) amount : \(String(format: "%.2f", self.amount)) \n"
        }
    }
    
    static func ==(lhs: Bill, rhs: Bill) -> Bool {
        return lhs.date == rhs.date && lhs.amount == rhs.amount && lhs.store! == rhs.store!
    }

}

extension Bill {
    public func outputString() -> String {
        if let category = self.store!.category {
            return "\(self.date), \(self.store!.name), \(self.amount), \(category.name)"
        } else {
            return "\(self.date), \(self.store!.name), \(self.amount),"
        }
        
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
