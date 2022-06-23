//
//  HighlightList.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import Foundation

struct HighlightListModel : Decodable {
    let count : Int
    let next : String?
    let previous: String?
    let results: [HighlightItemModel]
}

struct HighlightItemModel : Decodable {
    let id : Int64
    let text: String
    let note: String
    let location: Int
    let location_type: String
    let highlighted_at: String?
    let url: String?
    let color: String?
    let updated: String?
    let book_id: Int64?
    let tags: [BookTagModel]
}

struct BookTagModel: Decodable {
    let id : Int
    let name: String
}
