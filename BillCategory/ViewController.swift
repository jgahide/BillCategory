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
        
        self.printLineSeparator()
        print("Recherche d'un livre de compte Mastercard à importer ...")
        let mastercardBook:Book = Book(withBookName: "mastercard")
        mastercardBook.read()

        self.printLineSeparator()
        print("Recherche d'un livre de compte chèque à importer ...")
        let compteCourant:Book = Book(withBookName: "CompteCourant")
        compteCourant.read()
        
        self.printLineSeparator()
        print("Chargement du grand livre de compte ...")
        let book:Book = Book(withBookName: "compteTest")
        book.read()

        print("nombre de magasins : \(book.stores.count)")
        print("nombre de magasins non catégorisé : \(book.stores.filter {$0.category == nil}.count)")
        self.printLineSeparator()

        
        self.printLineSeparator()
        print("Importation du livre de compte Mastercard ...")
        book.importBook(mastercardBook)
        book.importBook(compteCourant)

        print("nombre de magasins après import : \(book.stores.count)")
        let categorylessStores = book.stores.filter {$0.category == nil}
        print("nombre de magasins non catégorisé après import : \(categorylessStores.count)")
        self.printLineSeparator()
        
        print("On va catégoriser les magasins sans catégorie")
        for store in categorylessStores {
            
            let possibleCategories = book.findCandidateCategories(forStore: store)
            let title = "* Categorisation du magasin : " + store.name + "\n nom complet = " + store.fullName
            let keys = Array(possibleCategories.keys)
            let chooseFromCandidateCategories : ChoiceQuestion = ChoiceQuestion(withQuestionTitle:title , andChoiceList: keys)
            
            let answer:Int = chooseFromCandidateCategories.ask()
            if chooseFromCandidateCategories.isAnswerIsAbort() {
                book.writeFile()
                exit(0)
            } else if chooseFromCandidateCategories.isAnswerIsOther() {
                let title = "Choisir une categorie existante : "
                let keys = Array(book.categories.keys)
                let chooseCategory : ChoiceQuestion = ChoiceQuestion(withQuestionTitle:title , andChoiceList: keys)
                let answer:Int = chooseCategory.ask()
                
                if chooseCategory.isAnswerIsOther() {
                    let title = "Veuillez entrer un nom pour une nouvelle catégorie : "
                    let enterNewCategory : SentenceQuestion = SentenceQuestion(withQuestionTitle: title)
                    let categoryName = enterNewCategory.ask()
                    let category : Category = Category(name:categoryName, storeName:store.name)
                    store.category = category
                    book.categories[categoryName] = category
                    print("Nouvelle Catégorie \(categoryName) créée")
                } else {
                    print("Categorie \(keys[answer]) assignée au magasin \(store.name)")
                    store.category = book.categories[keys[answer]]
                }
            } else {
                print("Categorie \(keys[answer]) assignée au magasin \(store.name)")
                store.category = possibleCategories[keys[answer]]
            }
        }
        
        // Sauvegarder le fichier
        book.writeFile()
        
    }

    func printLineSeparator() -> Void {
        print("--------------------------------\n")
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    

    
    
    
    
}
