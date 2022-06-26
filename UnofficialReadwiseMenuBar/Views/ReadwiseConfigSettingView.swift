//
//  ReadwiseConfigSettingView.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 26/06/2022.
//

import SwiftUI

struct ReadwiseConfigSettingView: View {
    
    //MARK: - AppStorage Keys
    @AppStorage(StorageKeys.api_key.rawValue) private var apiAuthTokenKey: String = ""
    
    @AppStorage(StorageKeys.key_validated.rawValue) private var keyValidated: Bool = false
    
    //MARK: - View Model
    @ObservedObject private var viewModel = ReadwiseConfigSettingViewVM()
    
    //MARK: - UI State
    @State private var validatation_status = ""
    @State private var labelColor : Color = .red
    
    var body: some View {
        VStack {
            
            Text("Get your Readwise API token from here and save it for receiving highlights you saved.")
                .font(.subheadline)
            
            Text("https://readwise.io/access_token")
                .underline()
            
            TextField("put api key here", text: $apiAuthTokenKey)
                .onSubmit {
                    
                }
                .frame(width: 250, height: 20.0, alignment: .center)
                .cornerRadius(12.0)
            
            Button("Check", action: checkToken)
            
            Text(validatation_status)
                .foregroundColor(labelColor)
            
        }.frame(width: 450, height: 250, alignment: .center)
    }
    
    private func checkToken() {
        
        // call Readwise check token api and validate token
        Task {
            await self.viewModel.checkToken(token: apiAuthTokenKey)
            
            if self.viewModel.status_code == 0 {
                // save AppStorage Key key_validated to True
                self.keyValidated = true
                print("key_validated = true")
                validatation_status = "Token successfully added"
                labelColor = .green
            } else {
                self.keyValidated = false
                validatation_status = "Invalid token"
                labelColor = .red
            }
        }
    }
}

struct ReadwiseConfigSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ReadwiseConfigSettingView()
    }
}

