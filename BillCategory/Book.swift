//
//  Book.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 18-03-01.
//  Copyright © 2018 Jerome GAHIDE. All rights reserved.
//

import Foundation

class Book {
    let filename : String
    var stores : Array <Store> = []
    var bills : Array <Bill> = []
    var categories : Dictionary<String, Category> = [:]
    
    init(withBookName filename:String) {
       self.filename = filename
    }
    
    public func read() -> Void {
        let fileDataString = self.loadFile()
//        let fileData = self.readfile()
//        let fileDataString = String(data: fileData as Data, encoding: .utf8)
        self.parseBook(fileData: fileDataString)
    }
    
    private func loadFile() -> String {
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocumentDirURL.appendingPathComponent(self.filename).appendingPathExtension("csv")
        print("Lecture du fichier \(fileURL.path)")
        
        var readString = "" // Used to store the file contents
        do {
            // Read the file contents
            readString = try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        return readString
    }
    
    private func readfile() -> NSData {
        let filePath = Bundle.main.path(forResource: self.filename, ofType: "csv")
        print("Lecture du fichier ", filePath!)
        return NSData(contentsOfFile:filePath!)!
    }
    
    private func parseBook(fileData:String?) -> Void  {
        let entries = fileData?.components(separatedBy:"\n")
        print("nombre de factures : \(entries?.count ?? 0)")
        
        for entry in entries! {
            let bookEntry = BookEntry(billStatementData: entry)
            if bookEntry.isValidStatement() {
                
                if let existingStore = self.stores.first(where: {$0.name == bookEntry.store!.name}) {
                    bookEntry.bill!.store = existingStore
                } else {
                    let store : Store = bookEntry.store!
                    if let category = self.readCategory(from:bookEntry) {
                        store.category = category
                    }
                    self.stores.append(store)
                }
                
                self.bills.append(bookEntry.bill!)
            }
        }
    }
    
    private func readCategory(from entry:BookEntry) -> Category? {
        var result : Category? = nil
        
        if let categoryName = entry.categoryName() {
            
            if let existingCategory = self.categories[categoryName] {
                existingCategory.addTags(fromStoreName: entry.store!.name)
                result = existingCategory
            } else {
                result = Category(name:categoryName, storeName:entry.store!.name)
                self.categories[categoryName] = result
            }
        }
        
        return result
    }

    public func writeFile() -> Void {
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocumentDirURL.appendingPathComponent(self.filename).appendingPathExtension("csv")
        print("Ecriture du fichier \(fileURL.path)")

        //"test".write(toFile: filePath, atomically: true, encoding: .utf8)
        var output:String = ""
        for bill in self.bills {
            output += bill.outputString() + "\n"
        }
        
//        print(output)
        
        do{
            try output.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch {
            print("Erreur d'ecriture sur le fichier : \(fileURL)")
        }
    }

    public func findCandidateCategories(forStore store:Store) -> Dictionary<String, Category> {
        let storeWords = store.name.components(separatedBy: " ")
        return self.categories.filter{ $1.tags.intersection(storeWords).count > 0 }
    }
}


