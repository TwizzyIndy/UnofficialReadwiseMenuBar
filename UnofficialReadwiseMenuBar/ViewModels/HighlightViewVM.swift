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
    @Published private var hightlight_list: HighlightListModel?
    @Published private var books_list: BooksListModel?
    
    //MARK: - For Core Data Handling
    var viewContext : NSManagedObjectContext?
    
    var currentHighlightItem : HighlightItemModel?
    
    var highlighted_text: String {
        guard let item = hightlight_list?.results.randomElement() else {
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
    
    func getHighlightList(token: String, completion: @escaping() -> Void)
    {
        ReadwiseAPI().getHighlightsList(token: token) { result in
            switch result {
            case .success(let p):
                DispatchQueue.main.async {
                    print("\(#function) ok")
                    self.hightlight_list = p
                    completion()
                }
            case .failure(_ ):
                print("error")
            }
        }
    }
    
    func getBooksList(token: String, completion: @escaping() -> Void)
    {
        ReadwiseAPI().getBooksList(token: token) { result in
            switch result {
            case .success(let models):
                DispatchQueue.main.async {
                    print("\(#function) ok")
                    self.books_list = models
                    completion()
                }
            case .failure(_ ):
                print("\(#function) error")
            }
        }
    }
    
    func fetchHighlightList(token: String) async {
        do {
            let highlightList = try await ReadwiseAPI().getHighlightsList(token: token)
            DispatchQueue.main.async {
                self.hightlight_list = highlightList
                print("\(#function) ok")
                
                self.saveHighlightListToDB()
            }
        } catch {
            print("\(#function) error")
        }
    }
    
    private func saveHighlightListToDB()
    {
        // save to CoreData
        guard let viewContext = self.viewContext,
        let hightlight_list = self.hightlight_list else {
            return
        }
        
        hightlight_list.results.forEach({ fetchedItem in
            
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
                } else { // if not exists
                    let itemToSave = NSEntityDescription.insertNewObject(forEntityName: "HighlightItemDataModel", into: viewContext) as! HighlightItemDataModel
                    itemToSave.id = fetchedItem.id
                    itemToSave.book_id = fetchedItem.book_id ?? 0
                    itemToSave.highlighted_at = fetchedItem.highlighted_at ?? ""
                    itemToSave.updated_at = fetchedItem.updated ?? ""
                    itemToSave.note = fetchedItem.note
                    itemToSave.tags = fetchedItem.tags as NSObject?
                    itemToSave.color = fetchedItem.color ?? ""
                    itemToSave.text = fetchedItem.text
                    itemToSave.location = Int64(fetchedItem.location)
                    itemToSave.location_type = fetchedItem.location_type
                    itemToSave.url = fetchedItem.url ?? ""
                    
                }
            } catch {
                print("failed to fetch highlight items")
            }
        })
        
        do {
            try viewContext.save()
        } catch {
            print("failed to save highlight items to db")
        }
    }
    
    func fetchBooksList(token: String) async {
        do {
            let booksList = try await ReadwiseAPI().getBooksList(token: token)
            DispatchQueue.main.async {
                self.books_list = booksList
                print("\(#function) ok")
            }
        } catch {
            print("\(#function) error")
        }
    }
    
    func getBookAuthor(bookId: Int64) -> String
    {
        guard let books_list = books_list else {
            return "N/A"
        }
        
        let filtered = books_list.results.filter { $0.id == bookId }
        if (filtered.isEmpty)
        {
            return "N/A"
        } else {
            return filtered.first?.author ?? "N/A"
        }
    }
    
    func getBookTitle(bookId: Int64) -> String
    {
        guard let books_list = books_list else {
            return "N/A"
        }
        
        let filtered = books_list.results.filter { $0.id == bookId }
        if (filtered.isEmpty)
        {
            return "N/A"
        } else {
            return filtered.first?.title ?? "N/A"
        }
    }
}
