//
//  HighlightView.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import SwiftUI

struct HighlightView: View {
    @ObservedObject private var highlightVM = HighlightViewVM()
    
    @State private var highlight_text = "N/A"
    @State private var author = "N/A"
    
    var body: some View {
        RadialGradient(gradient: Gradient(colors: [.orange, .yellow]), center: .topLeading, startRadius: 100, endRadius: 200)
            .ignoresSafeArea()
            .overlay(
        VStack {
            Text(highlight_text)
            Text(author)
            
            Button("Refresh", action: {
                highlight_text = self.highlightVM.highlighted_text
                author = self.highlightVM.author_name
            })
        }
        .onAppear()
        .task {
            await self.highlightVM.fetchHighlightList(token: "jJ1ZJ0TaO6eqEtHc8ZGo2i1LhkiaujtDlu4hk3cGZiUjufQdxz")
            await self.highlightVM.fetchBooksList(token: "jJ1ZJ0TaO6eqEtHc8ZGo2i1LhkiaujtDlu4hk3cGZiUjufQdxz")
            
            highlight_text = self.highlightVM.highlighted_text
            author = self.highlightVM.author_name
        }
        .frame(width: 400, height: 200, alignment: .center)
        .cornerRadius(12.0)
        )
    }
    
    
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView()
    }
}

