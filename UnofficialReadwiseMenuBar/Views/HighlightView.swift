//
//  HighlightView.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import SwiftUI

struct HighlightView: View {
    //MARK: - Core Data Context
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \HighlightItemDataModel.highlighted_at, ascending: true)],
                  animation: .default) var highlight_list_db: FetchedResults<HighlightItemDataModel>
    
    //MARK: - View Model
    @ObservedObject private var highlightVM : HighlightViewVM
    
    //MARK: - UI States
    @State private var highlight_text = "N/A"
    @State private var author = "N/A"
    @State private var bookTitle = "N/A"
    @State private var highlight_list_iter : IndexingIterator<FetchedResults<HighlightItemDataModel>>?

    
    //MARK: - AppStorage Keys
    @AppStorage(StorageKeys.api_key.rawValue) private var appStorageAPIKey: String = ""
    
    @AppStorage(StorageKeys.key_validated.rawValue) private var appStorageKeyValidated: Bool = false
    
    private let backgroundColor = Color(hex: 0xDAC2FF, alpha: 1.0)
    private let textColor = Color(hex: 0x975EEF, alpha: 1.0)
    
    //MARK: - Init
    init(context: NSManagedObjectContext) {
        self.highlightVM = HighlightViewVM(viewContext: context)
    }
    
    var body: some View {
        RadialGradient(gradient: Gradient(colors: [.white, backgroundColor]), center: .topLeading, startRadius: 20, endRadius: 70)
            .ignoresSafeArea()
            .overlay(
                Image("highlight_transparent_background")
                    .overlay(
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                // settings button
                                Button(action: {
                                    // show preferences window
                                    // https://stackoverflow.com/a/65356627
                                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                                    
                                }, label: {
                                    Image("ic_settings")
                                        .resizable()
                                        .frame(width: 20, height: 20, alignment: .center)
                                    
                                })
                                .buttonStyle(.borderless)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                            }
                            
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
                                    
                                    // get from Core Data first
                                    if (!self.highlight_list_db.isEmpty)
                                    {
                                        print("db is not empty")
                                        
                                        if let highlightItem = self.highlight_list_iter?.next() {
                                            highlight_text = highlightItem.text ?? "N/A"
                                            author = "N/A"
                                            bookTitle = "N/A"
                                            return
                                        }
                                    }
                                    
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
                                
                                // get from Core Data first
                                if (!self.highlight_list_db.isEmpty)
                                {
                                    print("db is not empty")
                                    
                                    self.highlight_list_iter = self.highlight_list_db.makeIterator()
                                    
                                    if let highlightItem = self.highlight_list_iter?.next() {
                                        highlight_text = highlightItem.text ?? "N/A"
                                        
                                        // TODO: need to parse author and bookTitle
                                        author = "N/A"
                                        bookTitle = "N/A"
                                        return
                                    }
                                }
                                
                                // get from API
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
        HighlightView(context: PersistenceController.preview.container.viewContext).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

