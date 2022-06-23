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
    
    var body: some View {
        VStack {
            Text(highlight_text)
            
            Button("Refresh", action: {
                highlight_text = self.highlightVM.highlighted_text
            })
        }
        .onAppear() {
            self.highlightVM.getHighlightList(token: "jJ1ZJ0TaO6eqEtHc8ZGo2i1LhkiaujtDlu4hk3cGZiUjufQdxz")
        }
        .frame(width: 300, height: 300, alignment: .center)
    }
    
    
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView()
    }
}

