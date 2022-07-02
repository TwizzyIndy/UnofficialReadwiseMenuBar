//
//  Persistence.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // For Xcode Canvas(Preview)
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            
            // for highlight items preview
            let newHighlightItem = HighlightItemDataModel(context: viewContext)
            newHighlightItem.id = 34534
            newHighlightItem.book_id = 234
            newHighlightItem.highlighted_at = "2234"
            newHighlightItem.location_type = "location"
            newHighlightItem.note = ""
            newHighlightItem.tags = nil
            newHighlightItem.color = ""
            newHighlightItem.text = "The goal of this book is to change your perception about wealth and money. Believe that retirement at any age is possible. Believe that old age is not a prerequisite to wealth. Believe that a job is just as risky as a business. Believe that the stock market isn't a guaranteed path to riches. Believe that you can be retired just a few years from today."
            newHighlightItem.location = 234234
            newHighlightItem.url = "https://demo.com"
            
            // for book list data model
            let newBooklistItem = BookItemDataModel(context: viewContext)
            newBooklistItem.id = 34234
            newBooklistItem.updated_at = ""
            newBooklistItem.tags = nil
            newBooklistItem.asin = "23423"
            newBooklistItem.author = "The Author"
            newBooklistItem.category = "self-help"
            newBooklistItem.cover_image_url = "https://demo.com"
            newBooklistItem.highlights_url = "https://demo.com"
            newBooklistItem.num_highlights = Int32(233)
            newBooklistItem.source = "https://demo.com"
            newBooklistItem.source_url = "https://demo.com"
            newBooklistItem.last_highlight_at = ""
            newBooklistItem.title = "The book title"
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "UnofficialReadwiseMenuBar")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        print("\(container.persistentStoreDescriptions.first?.url)")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
