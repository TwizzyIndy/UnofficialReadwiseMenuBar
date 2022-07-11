//
//  HighlightViewVM.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import Foundation
import CoreData

class HighlightViewVM: ObservableObject {
    
    //MARK: - Published Objects
    @Published private var auth_status_code: Int?
    @Published private var highlight_list_array: [HighlightListModel]?
    @Published private var books_list_array: [BooksListModel]?
    
    //MARK: - For Core Data Handling
    var viewContext : NSManagedObjectContext?
    
    var currentHighlightItem : HighlightItemModel?
    
    var highlighted_text: String {
        guard let item = highlight_list_array?.randomElement()?.results.randomElement() else {
            return "N/A"
        }
        
        currentHighlightItem = item
        return item.text
    }
    
    var author_name: String {
        guard let currentHighlightItem = currentHighlightItem else {
            return "N/A"
        }
        
        if let bookId = currentHighlightItem.book_id {
            return getBookAuthor(bookId: bookId)
        }
        return "N/A"
    }
    
    var book_title: String {
        guard let currentHighlightItem = currentHighlightItem else {
            return "N/A"
        }
        
        if let bookId = currentHighlightItem.book_id {
            return getBookTitle(bookId: bookId)
        }
        return "N/A"
    }
    
    // MARK: - Init
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func checkToken(token: String) {
        ReadwiseAPI().checkToken(token: token) { result in
            switch result {
            case .success(let status_code):
                if status_code == 0 {
                    DispatchQueue.main.async {
                        print("ok")
                        self.auth_status_code = status_code
                    }
                } else {
                    print("invalid status code")
                }
            case .failure(_):
                print("error")
            }
        }
    }
    
    
    func fetchHighlightList(token: String) async {
        do {
            let highlightArrayList = try await ReadwiseAPI().getHighlightsListAll(token: token)
            
            DispatchQueue.main.async {
                self.highlight_list_array = highlightArrayList
                print("\(#function) ok")

                // save to db
                self.saveHighlightListToDB()
            }
        } catch ResponseError.BadURL {
            print("\(#function) bad url")
        } catch let error as NSError {
            print("\(#function) \(error.localizedDescription)")
        }
    }
    
    func fetchBooksList(token: String) async {
        do {
            let booksListArray = try await ReadwiseAPI().getBooksListAll(token: token)
            
            DispatchQueue.main.async {
                self.books_list_array = booksListArray
                print("\(#function) ok")
                
                // save to db
                self.saveBooksListToDB()
            }
        } catch ResponseError.BadURL {
            print("\(#function) bad url")

        } catch let error as NSError {
            print("\(#function) \(error.localizedDescription)")

        }
    }
    
    private func saveHighlightListToDB()
    {
        // save to CoreData
        guard let viewContext = viewContext,
        let highlight_list_array = self.highlight_list_array else {
            return
        }
        
        highlight_list_array.forEach({ highlight_list in
            
            highlight_list.results.forEach({ fetchedItem in
                
                // Make FetchRequest from CoreData
                let request: NSFetchRequest<HighlightItemDataModel> = HighlightItemDataModel.fetchRequest()
                
                // only matched result with fetchedItem's id
                request.predicate = NSPredicate(format: "id == %lld", fetchedItem.id)
                
                do {
                    let storedItems = try viewContext.fetch(request)
                    
                    // if already exists
                    if let storeItem = storedItems.first {
                        //TODO: .. do something here
                        print("already exists")
                        return
                    } else { // if not exists
                        let itemToSave = NSEntityDescription.insertNewObject(forEntityName: "HighlightItemDataModel", into: viewContext) as! HighlightItemDataModel
                        itemToSave.id = fetchedItem.id
                        itemToSave.book_id = fetchedItem.book_id ?? 0
                        itemToSave.highlighted_at = fetchedItem.highlighted_at ?? ""
                        itemToSave.updated_at = fetchedItem.updated ?? ""
                        itemToSave.tags = fetchedItem.tags as? [NSObject]
                        itemToSave.note = fetchedItem.note
                        itemToSave.color = fetchedItem.color ?? ""
                        itemToSave.text = fetchedItem.text
                        itemToSave.location = Int64(fetchedItem.location)
                        itemToSave.location_type = fetchedItem.location_type
                        itemToSave.url = fetchedItem.url ?? ""
                        
                    }
                } catch let error as NSError {
                    print("failed to fetch highlight items. \(error.localizedDescription)")
                }
            })
        })
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("failed to save highlight items to db. \(error.localizedDescription)")
        }
        
    }

    private func saveBooksListToDB() {
        // save to CoreData
        guard let viewContext = self.viewContext,
        let books_list_array = self.books_list_array else {
            return
        }
        
        books_list_array.forEach({ books_list in
            books_list.results.forEach({ fetchedItem in
                // Make FetchRequest from CoreData
                let request: NSFetchRequest<BookItemDataModel> = BookItemDataModel.fetchRequest()
                
                // only matched result with fetchedItem's id
                request.predicate = NSPredicate(format: "id == %lld", fetchedItem.id)
                
                do {
                    let storedItems = try viewContext.fetch(request)
                    
                    // if already exists
                    if let storeItem = storedItems.first {
                        //TODO: .. do something here
                        print("already exists")
                        return
                    } else { // if not exists
                        
                        let itemToSave = NSEntityDescription.insertNewObject(forEntityName: "BookItemDataModel", into: viewContext) as! BookItemDataModel
                        
                        itemToSave.id = fetchedItem.id
                        itemToSave.updated_at = fetchedItem.updated ?? ""
                        itemToSave.asin = fetchedItem.asin ?? ""
                        itemToSave.tags = fetchedItem.tags as? [NSObject]
                        itemToSave.author = fetchedItem.author ?? ""
                        itemToSave.category = fetchedItem.category ?? ""
                        itemToSave.cover_image_url = fetchedItem.cover_image_url ?? ""
                        itemToSave.highlights_url = fetchedItem.highlights_url ?? ""
                        itemToSave.num_highlights = Int32(fetchedItem.num_highlights ?? 0)
                        itemToSave.source = fetchedItem.source ?? ""
                        itemToSave.source_url = fetchedItem.source_url ?? ""
                        itemToSave.last_highlight_at = fetchedItem.last_highlight_at ?? ""
                        itemToSave.title = fetchedItem.title ?? ""
                        
                    }
                } catch let error as NSError {
                    print("failed to fetch book list items.  \(error.localizedDescription)")
                }
            })
        })
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("failed to save book list items to db. \(error.localizedDescription)")
        }
    }
    
    private func getBookAuthor(bookId: Int64) -> String
    {
        guard let books_list_array = books_list_array else {
            return "N/A"
        }
        
        var result = "N/A"
        
        books_list_array.forEach({ books_list in
            
            let filtered = books_list.results.filter { $0.id == bookId }
            
            if (filtered.isEmpty)
            {
                result = "N/A"
            } else {
                result = filtered.first?.author ?? "N/A"
            }
        })
        return result
    }
    
    private func getBookTitle(bookId: Int64) -> String
    {
        guard let books_list_array = books_list_array else {
            return "N/A"
        }
        
        var result = "N/A"

        books_list_array.forEach({ books_list in
            
            let filtered = books_list.results.filter { $0.id == bookId }
            
            if (filtered.isEmpty)
            {
                result = "N/A"
            } else {
                result = filtered.first?.title ?? "N/A"
            }
            
        })
        
        return result
    }
}
