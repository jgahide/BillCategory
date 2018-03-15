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
    
    private func parseBook(fileData:String?) -> Void  {
        let entries = fileData?.components(separatedBy:"\n")
        print("nombre de factures : \(entries?.count ?? 0)")
        
        for entry in entries! {
            let bookEntry:BookEntry = self.bookEntryForType(entry)
            if bookEntry.isValidStatement() {
                
                if let existingStore = self.stores.first(where: {$0.name == bookEntry.bill!.store!.name}) {
                    bookEntry.bill!.store = existingStore
                } else {
                    let store : Store = bookEntry.bill!.store!
                    if let category = self.readCategory(from:bookEntry) {
                        store.category = category
                    }
                    self.stores.append(store)
                }
                
                self.bills.append(bookEntry.bill!)
            }
        }
    }
    
    private func bookEntryForType(_ entry: String) -> BookEntry {
        if self.filename == "mastercard" {
            return MastercardBookEntry(billStatementData: entry)
        } else if self.filename == "CompteCourant" {
            return ChequeAccountBookEntry(billStatementData: entry)
        } else {
            return GreatBookEntry(billStatementData: entry)
        }
    }
    
    private func readCategory(from entry:BookEntry) -> Category? {
        var result : Category? = nil
        
        if let categoryName = entry.categoryName() {
            
            if let existingCategory = self.categories[categoryName] {
                existingCategory.addTags(fromStoreName: entry.bill!.store!.name)
                result = existingCategory
            } else {
                result = Category(name:categoryName, storeName:entry.bill!.store!.name)
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
    
    public func importBook(_ aBook : Book) -> Void {
        
        for var bill in aBook.bills {
            if self.bills.first(where: {$0 == bill}) == nil {
                if let existingStore = self.stores.first(where: {$0.name == bill.store!.name}) {
                    bill.store = existingStore
                    self.bills.append(bill)
                } else {
                    self.stores.append(bill.store!)
                    self.bills.append(bill)
                }
            }
        }
        
    }
    
}


