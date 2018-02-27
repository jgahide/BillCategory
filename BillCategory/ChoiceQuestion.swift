//
//  ChoiceQuestion.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 18-02-27.
//  Copyright © 2018 Jerome GAHIDE. All rights reserved.
//

import Foundation

class ChoiceQuestion {
    
    let title   :String
    let choices :Array<String>
    var answer  :Int
    
    init(withQuestionTitle title:String, andChoiceList choices:Array<String>) {
        self.title = title
        self.choices = choices
        self.answer = -1
    }
    
    func ask() -> Int {
        print("\(self.title) \n")
        printChoicesList()
        repeat {
            self.answer = readUserAnswer()
        } while (!(0 ..< self.choices.count+1 ~= self.answer))
        return self.answer
    }
    
    func printChoicesList() -> Void {
        var index: Int = 0
        for choice in choices {
            print("\(index) \(choice) ")
            index = index + 1
        }
        print("\(index) OTHER ")
    }
    
    func readUserAnswer() -> Int {
        print("Veuillez choisir une réponse : ")
        let standardInput = FileHandle.standardInput
        let input = standardInput.availableData
        let inputString = String(data: input as Data, encoding: .utf8)?.trimmingCharacters(in: .newlines)
        print("=>\(inputString ?? "")")
        
        return Int(inputString!)!
    }
    
    func isAnswerIsOther() -> Bool {
        return self.answer == self.choices.count
    }
    
}
