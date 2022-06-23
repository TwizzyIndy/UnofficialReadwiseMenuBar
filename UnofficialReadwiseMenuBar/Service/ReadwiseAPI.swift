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
}
