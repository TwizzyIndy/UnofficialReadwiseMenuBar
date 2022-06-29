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
    
    private let backgroundColor = Color(hex: 0xDAC2FF, alpha: 1.0)
    private let textColor = Color(hex: 0x975EEF, alpha: 1.0)
    
    var body: some View {
        RadialGradient(gradient: Gradient(colors: [.white, backgroundColor]), center: .topLeading, startRadius: 20, endRadius: 70)
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
                                    .foregroundColor(textColor)
                            }
                            
                            HStack {
                                Text(author)
                                    .bold()
                                    .foregroundColor(textColor)
                                
                                Text("—— from " + bookTitle)
                                    .foregroundColor(textColor)
                            }
                            
                            HStack {
                                Button("⬅️", action: {
                                    print("prev")
                                })
                                .buttonStyle(.borderless)
                                .frame(width: 50, height: 50, alignment: .center)
                                
                                Spacer()
                                
                                Button(action: {
                                    highlight_text = self.highlightVM.highlighted_text
                                    author = self.highlightVM.author_name
                                    bookTitle = self.highlightVM.book_title
                                    
                                }, label: {
                                    Text(" ")
                                })
                                .buttonStyle(.borderless)
                                .frame(width: 50, height: 50, alignment: .center)
                            }
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

