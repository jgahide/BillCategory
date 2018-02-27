//
//  ViewController.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 17-11-14.
//  Copyright © 2017 Jerome GAHIDE. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var categories : Dictionary<String, Category> = [:]
    var stores : Array <Store> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let fileData = read(filename: "compteTest")
        let fileDataString = String(data: fileData as Data, encoding: .utf8)
        
        self.parseStatments(fileData: fileDataString)
        
        print("nombre de magasins : \(stores.count)")
        let categorylessStore = stores.filter {$0.category == nil}
        print("nombre de magasins non catégorisé : \(categorylessStore.count)")
        
        print("On va catégoriser les magasins sans catégorie")
        for store in categorylessStore {
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
    
    func parseStatments(fileData:String?) -> Void  {
        let billStatements = fileData?.components(separatedBy:"\n")
        print("nombre de factures : \(billStatements?.count ?? 0)")
        
        for billStatment in billStatements! {
            
            let billStatamentReader = BillStatementReader(billStatementData: billStatment)
            if billStatamentReader.isValidStatement() {
                
                if let existingStore = self.stores.first(where: {$0.name == billStatamentReader.storeName}) {
                    existingStore.bills.append(billStatamentReader.bill!)
                } else {
                    let store : Store = Store(name:billStatamentReader.storeName!)
                    store.bills.append(billStatamentReader.bill!)
                    
                    if let category = self.readCategory(from:billStatamentReader) {
                        store.category = category
                    }
                    
                    self.stores.append(store)
                }
                
            }
            
        }
    }
    
    func readCategory(from reader:BillStatementReader) -> Category? {
        var result : Category? = nil
        
        if let categoryName = reader.categoryName() {
            
            if let existingCategory = categories[categoryName] {
                existingCategory.addTags(fromStoreName: reader.storeName!)
                result = existingCategory
            } else {
                result = Category(name:categoryName, storeName:reader.storeName!)
                self.categories[categoryName] = result
            }
        }
        
        return result
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
