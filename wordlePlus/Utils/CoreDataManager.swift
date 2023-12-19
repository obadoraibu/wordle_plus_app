//
//  CoreDataManager.swift
//  wordlePlus
//
//  Created by Egor Zavyalov on 18.12.2023.
//

import Foundation
import CoreData

struct CoreDataManager {

    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WordModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }

        return container
    }()
    
    @discardableResult
    func createWord(word: String, definition: String) -> WordEntity? {
        let context = persistentContainer.viewContext
        let newWord = WordEntity(context: context)
        newWord.word = word
        newWord.definition = definition
        do {
            try context.save()
            return newWord
        } catch let error {
            print("Failed to create: \(error)")
        }
        return nil
    }

    func fetchWords() -> [WordEntity]? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<WordEntity>(entityName: "WordEntity")
        do {
            let words = try context.fetch(fetchRequest)
            return words
        } catch let error {
            print("Failed to fetch companies: \(error)")
        }
        return nil
    }

    func deleteWord(word: WordEntity) {
        let context = persistentContainer.viewContext
        context.delete(word)
        do {
            try context.save()
        } catch let error {
            print("Failed to delete: \(error)")
        }
    }
}
