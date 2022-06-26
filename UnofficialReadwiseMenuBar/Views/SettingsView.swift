//
//  SettingsView.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 26/06/2022.
//

import SwiftUI


struct SettingsView: View {
    var body: some View {
        TabView {
            ReadwiseConfigSettingView()
                .tabItem {
                    Label("Config", systemImage: "key")
                }
        }
        .frame(width: 450, height: 250, alignment: .center)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

