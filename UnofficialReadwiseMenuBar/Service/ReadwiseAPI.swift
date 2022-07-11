//
//  ReadwiseAPI.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import Foundation

enum AuthError: Error {
    case BadURL
    case TokenInvalid
}

enum ResponseError: Error {
    case BadURL
    case NoData
    case Error
    case DecodingError
}

class ReadwiseAPI {
    
    func checkToken(token: String, completion: @escaping(Result<Int?, AuthError>) -> Void) {
        guard let authUrl = URL(string: "https://readwise.io/api/v2/auth/") else { return completion(.failure(.BadURL)) }
        
        var request = URLRequest(url:authUrl)
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                print("Error")
                return completion(.failure(.TokenInvalid))
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    return completion(.success(0))
                } else {
                    return completion(.failure(.TokenInvalid))
                }
            }

        }.resume()
    }
    
    /// Get highlighted list from Readwise API
    /// - Parameters:
    ///   - token: the generated user's token
    ///   - completion: the completion handler
    func getHighlightsList(token: String, completion: @escaping(Result<HighlightListModel?, ResponseError>) -> Void)
    {
        guard let highlightListUrl = URL(string: "https://readwise.io/api/v2/highlights/") else { return completion(.failure(.BadURL)) }
        
        var request = URLRequest(url:highlightListUrl)
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("error in \(#function)")
                return completion(.failure(.Error))
            }
            
            if let data = data {
                let listResponse = try? JSONDecoder().decode(HighlightListModel.self, from: data)
                
                if let listResponse = listResponse {
                    completion(.success(listResponse))
                } else {
                    completion(.failure(.DecodingError))
                }
            }
            
        }.resume()
    }
    
    func getBookDetail(token: String, bookId: Int64, completion: @escaping(Result<BookDetailModel, ResponseError>) -> Void)
    {
        guard let bookDetailUrl = URL(string: "https://readwise.io/api/v2/books/\(bookId)/") else { return completion(.failure(.BadURL)) }
        
        var request = URLRequest(url:bookDetailUrl)
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("error in \(#function)")
                return completion(.failure(.Error))
            }
            
            if let data = data {
                let bookDetail = try? JSONDecoder().decode(BookDetailModel.self, from: data)
                
                if let bookDetail = bookDetail {
                    completion(.success(bookDetail))
                } else {
                    completion(.failure(.DecodingError))
                }
            }
        }.resume()
    }
    
    func getBooksList(token: String, completion: @escaping(Result<BooksListModel, ResponseError>) -> Void)
    {
        guard let bookDetailUrl = URL(string: "https://readwise.io/api/v2/books/") else { return completion(.failure(.BadURL)) }
        
        var request = URLRequest(url:bookDetailUrl)
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("error in \(#function)")
                return completion(.failure(.Error))
            }
            
            if let data = data {
                let booksList = try? JSONDecoder().decode(BooksListModel.self, from: data)
                
                if let booksList = booksList {
                    completion(.success(booksList))
                } else {
                    completion(.failure(.DecodingError))
                }
            }
        }.resume()
    }
    
    func getHighlightsList(token: String) async throws -> HighlightListModel {
        guard let highlightListUrl = URL(string: "https://readwise.io/api/v2/highlights/") else { throw ResponseError.BadURL }
        
        var request = URLRequest(url:highlightListUrl)
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ResponseError.Error
        }
        
        return try JSONDecoder().decode(HighlightListModel.self, from: data)
    }
    
    func getHighlightsListAll(token: String) async throws -> [HighlightListModel] {
        guard let highlightListUrl = URL(string: "https://readwise.io/api/v2/highlights/") else { throw ResponseError.BadURL }
        
        var result = [HighlightListModel]()
        
        let firstHighlightList = try await getHighlightsListWithURL(token: token, url: highlightListUrl)
        
        // append first item
        result.append(firstHighlightList)
        
        var nextUrlString : String? = nil
        
        if let next = firstHighlightList.next {
            guard let nextUrl = URL(string: next) else { throw ResponseError.BadURL }
            let nextItem = try await getHighlightsListWithURL(token: token, url: nextUrl)
            
            // ok, add second one here
            result.append(nextItem)
            
            if nextItem.next != nil {
                nextUrlString = nextItem.next
                
                repeat {
                    guard let nextUrl = URL(string: nextUrlString ?? "") else { throw ResponseError.BadURL }
                    let nextItem = try await getHighlightsListWithURL(token: token, url: nextUrl)
                    
                    result.append(nextItem)
                    nextUrlString = nextItem.next
                    
                } while nextUrlString != nil
            }
        }
        
        return result
    }
    private func getHighlightsListWithURL(token: String, url: URL) async throws -> HighlightListModel {
        
        let highlightListUrl = url
        
        var request = URLRequest(url:highlightListUrl)
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 429 else {
            throw ResponseError.Error
        }
        
        // handle request rate limits based on statusCode

        // statusCode 429 is Too Many Requests
        if httpResponse.statusCode == 429 {
            let retryAfterString = httpResponse.value(forHTTPHeaderField: "Retry-After") ?? "60"
            let retryAfter = Int(retryAfterString) ?? 60
            
            print("Need to wait for \(retryAfter) seconds")
            
            try? await Task.sleep(nanoseconds: UInt64(retryAfter) * 1_000_000_000)
            
            // run again ?
            return try await getHighlightsListWithURL(token: token, url: url)
        }
        
        let responseJson = try JSONDecoder().decode(HighlightListModel.self, from: data)
        return responseJson
    }
    func getBooksList(token: String) async throws -> BooksListModel {
        guard let bookDetailUrl = URL(string: "https://readwise.io/api/v2/books/") else { throw ResponseError.BadURL }
        
        var request = URLRequest(url:bookDetailUrl)
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ResponseError.Error
        }
        
        return try JSONDecoder().decode(BooksListModel.self, from: data)
    }
    
    func checkToken(token: String) async throws -> Int {
        guard let authUrl = URL(string: "https://readwise.io/api/v2/auth/") else { throw ResponseError.BadURL }
        
        var request = URLRequest(url:authUrl)
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 else {
                  throw AuthError.TokenInvalid
              }
        
        return 0
    }
}
