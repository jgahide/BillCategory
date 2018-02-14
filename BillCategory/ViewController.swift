//
//  ViewController.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 17-11-14.
//  Copyright © 2017 Jerome GAHIDE. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let fileData = read(filename: "compteTest")
        let fileDataString = String(data: fileData as Data, encoding: .utf8)
        
        let storeAndCategories = self.loadStatments(fileData: fileDataString)
        let stores : Array <Store> = storeAndCategories.0
        var categories : Dictionary = storeAndCategories.1
        
        print("nombre de magasins : \(stores.count)")
        let categorylessStore = stores.filter {$0.category == nil}
        print("nombre de magasins sans categorie : \(categorylessStore.count)")

        // Handle category less stores.
        for store in stores {
            print(store)
            
            // find  category for the user
            let storeWords = store.name.components(separatedBy: " ")
            let matchingCategories = categories.filter{ $1.tags.intersection(storeWords).count > 0 }
            printCategories(matchingCategories)
            var answer:Int = readUserAnswer()
            
            if 0 ..< matchingCategories.count ~= answer {
                
            } else {
                // ask the user to choose a category
                print("choose a catogory from the list : ")
                printCategories(categories)
                answer = readUserAnswer()
                if 0 ..< matchingCategories.count ~= answer {
                    
                } else {
                    // create a new Category.
                }
            }
            
            
        }
        
        
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func read(filename: String) -> NSData {
        let filePath = Bundle.main.path(forResource: filename, ofType: "csv")
        let data     = NSData(contentsOfFile:filePath!)
        
        return data!;
    }
    
    func loadStatments(fileData:String?) -> (Array <Store>, Dictionary<String, Category>)  {
        
        let billStatements = fileData?.components(separatedBy:"\n")
        print("nombre de factures : \(billStatements?.count ?? 0)")
        
        var stores : Array <Store> = Array()
        var categories : Dictionary = [String:Category]()
        
        for billStatment in billStatements! {
            let billParts = billStatment.split(separator: ",")
            if billParts.count > 0 {
                
                let bill : Bill = Bill(date:String(billParts[0]), amount: Float(billParts[2])!)
                let storeName = self.storeName(billStatement: billStatment)
                
                if let existingStore = stores.first(where: {$0.name == storeName}) {
                    existingStore.bills.append(bill)
                } else {
                    let store : Store = Store(name:storeName)
                    store.bills.append(bill)
                    
                    // Category thing.
                    if self.hasACategory(billStatement:billStatment) {
                        
                        let categoryName = String(billParts[3])
                        if let existingCategory : Category = categories[categoryName] {
                            store.category = existingCategory
                            existingCategory.addTags(fromStoreName: storeName)
                        } else {
                            let category : Category = Category(name:categoryName, storeName:storeName)
                            categories[categoryName] = category
                            store.category = category
                        }
                        
                    }
                    
                    stores.append(store)
                }
            }
        }

        return (stores, categories)
        
    }
    
    func hasACategory(billStatement:String) -> Bool {
        let billParts = billStatement.split(separator: ",")
        return billParts.count > 3
    }
    
    func storeName(billStatement:String) -> String {
        let billParts = billStatement.split(separator: ",")
        let longStoreName = String(billParts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        var shortStoreName = longStoreName
        
        let words = longStoreName.components(separatedBy: " ")
        if words.count > 3 {
            let firstWords = words[0...2] // keep the 3 first words
            shortStoreName = firstWords.joined(separator: " ")
        }
        
        return shortStoreName
    }
    
    func printCategories(_ categories:Dictionary<String, Category>) -> Void {
        var index: Int = 0
        categories.forEach() {
            print("\(index) \($0.key) ")
            index = index + 1
        }
        print("\(index) OTHER ")
    }
    
    func readUserAnswer() -> Int {
        print("Please choose an answer:")
        let standardInput = FileHandle.standardInput
        let input = standardInput.availableData
        let inputString = String(data: input as Data, encoding: .utf8)?.trimmingCharacters(in: .newlines)
        print("=>\(inputString ?? "")")
        
        return Int(inputString!)!
    }
    
}
