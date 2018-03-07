//
//  ChoiceQuestion.swift
//  BillCategory
//
//  Created by Jerome GAHIDE on 18-02-27.
//  Copyright © 2018 Jerome GAHIDE. All rights reserved.
//

import Foundation

protocol Question {
    associatedtype AnswerType
    var title  :String {get set}
    var answer :AnswerType {get set}
    
    func ask() -> AnswerType
}

extension Question {
    
    func readUserAnswer() -> String {
        let standardInput = FileHandle.standardInput
        let input = standardInput.availableData
        let inputString = String(data: input as Data, encoding: .utf8)?.trimmingCharacters(in: .newlines)
        print("=>\(inputString ?? "")")
        
        return inputString!
    }
}

class ChoiceQuestion : Question {
    typealias AnswerType = Int
    
    var title: String
    var answer: Int
    let choices :Array<String>
    
    init(withQuestionTitle title:String, andChoiceList choices:Array<String>) {
        self.title = title
        self.choices = choices
        self.answer = -1
    }
    
    func ask() -> Int {
        print("\(self.title) \n")
        printChoicesList()
        repeat {
            print("Veuillez choisir une réponse : ")
            self.answer = Int(readUserAnswer())!
        } while (!(0 ..< self.choices.count+2 ~= self.answer))
        return self.answer
    }
    
    func printChoicesList() -> Void {
        var index: Int = 0
        for choice in choices {
            print("\(index) \(choice) ")
            index = index + 1
        }
        print("\(index) OTHER ")
        index+=1
        print("\(index) Abort ")
    }
    
    func isAnswerIsOther() -> Bool {
        return self.answer == self.choices.count
    }

    func isAnswerIsAbort() -> Bool {
        return self.answer == self.choices.count+1
    }

    
}

class SentenceQuestion : Question {
    typealias AnswerType = String
    
    var title: String
    var answer: String
    
    init(withQuestionTitle title:String) {
        self.title = title
        self.answer = ""
    }

    func ask() -> String {
        print("\(self.title) \n")
        self.answer = readUserAnswer()
        return self.answer
    }
}
