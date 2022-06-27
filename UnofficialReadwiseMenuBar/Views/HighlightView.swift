//
//  HighlightView.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import SwiftUI

struct HighlightView: View {
    
    //MARK: - View Model
    @ObservedObject private var highlightVM = HighlightViewVM()
    
    //MARK: - UI States
    @State private var highlight_text = "N/A"
    @State private var author = "N/A"
    @State private var bookTitle = "N/A"
    
    //MARK: - AppStorage Keys
    @AppStorage(StorageKeys.api_key.rawValue) private var appStorageAPIKey: String = ""
    
    @AppStorage(StorageKeys.key_validated.rawValue) private var appStorageKeyValidated: Bool = false
    
    var body: some View {
        RadialGradient(gradient: Gradient(colors: [.orange, .yellow]), center: .topLeading, startRadius: 100, endRadius: 200)
            .ignoresSafeArea()
            .overlay(
                Image("highlight_transparent_background")
                    .overlay(
                        VStack {
                            ScrollView(.vertical, showsIndicators: false) {
                                Text(highlight_text)
                                    .italic()
                                    .font(.custom("Georgia", size: 14.0))
                                    .padding()
                                    .multilineTextAlignment(.center)
                            }
                            
                            HStack {
                                Text(author)
                                    .bold()
                                
                                Text("—— from " + bookTitle)
                            }
                            
                            Button("Refresh", action: {
                                highlight_text = self.highlightVM.highlighted_text
                                author = self.highlightVM.author_name
                                bookTitle = self.highlightVM.book_title
                            })
                        }
                            .onAppear()
                            .task {
                                await self.highlightVM.fetchHighlightList(token: appStorageAPIKey)
                                await self.highlightVM.fetchBooksList(token: appStorageAPIKey)
                                
                                highlight_text = self.highlightVM.highlighted_text
                                author = self.highlightVM.author_name
                                bookTitle = self.highlightVM.book_title
                            }
                            .frame(width: 400, height: 200, alignment: .center)
                            .cornerRadius(12.0)
                    )
            )
    }
    
    
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView()
    }
}

