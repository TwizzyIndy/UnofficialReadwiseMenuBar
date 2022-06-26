//
//  HighlightViewVM.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import Foundation

class HighlightViewVM: ObservableObject {
    
    @Published private var auth_status_code: Int?
    @Published private var hightlight_list: HighlightListModel?
    @Published private var books_list: BooksListModel?
    
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
            }
        } catch {
            print("\(#function) error")
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
