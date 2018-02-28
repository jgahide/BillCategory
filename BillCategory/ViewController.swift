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

        self.printLineSeparator()
        let fileData = read(filename: "compteTest")
        let fileDataString = String(data: fileData as Data, encoding: .utf8)
        
        self.parseStatments(fileData: fileDataString)
        
        print("nombre de magasins : \(stores.count)")
        let categorylessStores = stores.filter {$0.category == nil}
        print("nombre de magasins non catégorisé : \(categorylessStores.count)")
        self.printLineSeparator()
        
        print("On va catégoriser les magasins sans catégorie")
        for store in categorylessStores {
            
            let possibleCategories = self.findCandidateCategories(forStore: store)
            let title = "* Categorisation du magasin : " + store.name
            let keys = Array(possibleCategories.keys)
            let chooseFromCandidateCategories : ChoiceQuestion = ChoiceQuestion(withQuestionTitle:title , andChoiceList: keys)
            
            let answer:Int = chooseFromCandidateCategories.ask()
            if chooseFromCandidateCategories.isAnswerIsOther() {
                let title = "Choisir une categorie existante : "
                let keys = Array(self.categories.keys)
                let chooseCategory : ChoiceQuestion = ChoiceQuestion(withQuestionTitle:title , andChoiceList: keys)
                let answer:Int = chooseCategory.ask()
                
                if chooseCategory.isAnswerIsOther() {
                    let title = "Veuillez entrer un nom pour une nouvelle catégorie : "
                    let enterNewCategory : SentenceQuestion = SentenceQuestion(withQuestionTitle: title)
                    let categoryName = enterNewCategory.ask()
                    let category : Category = Category(name:categoryName, storeName:store.name)
                    store.category = category
                    self.categories[categoryName] = category
                    print("Nouvelle Catégorie \(categoryName) créée")
                } else {
                    print("Categorie \(keys[answer]) assignée au magasin \(store.name)")
                    store.category = possibleCategories[keys[answer]]
                }
                
            } else {
                print("Categorie \(keys[answer]) assignée au magasin \(store.name)")
                store.category = possibleCategories[keys[answer]]
            }
        }
        
        // Sauvegarder le fichier
        
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func read(filename: String) -> NSData {
        let filePath = Bundle.main.path(forResource: filename, ofType: "csv")
        print("Lecture du fichier ", filePath!)
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
    
    func printLineSeparator() -> Void {
        print("--------------------------------\n")
    }
    
    func findCandidateCategories(forStore store:Store) -> Dictionary<String, Category> {
        let storeWords = store.name.components(separatedBy: " ")
        return categories.filter{ $1.tags.intersection(storeWords).count > 0 }
    }
    
}
