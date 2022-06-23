//
//  BooksListModel.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import Foundation

struct BooksListModel : Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [BookDetailModel]
}


struct BookDetailModel : Decodable {
    let id: Int64
    let title: String?
    let author: String?
    let category: String?
    let source: String?
    let num_highlights: Int?
    let last_highlight_at: String?
    let updated: String?
    let cover_image_url: String?
    let highlights_url: String?
    let source_url: String?
    let asin: String?
    let tags: [BookTagModel]
}
