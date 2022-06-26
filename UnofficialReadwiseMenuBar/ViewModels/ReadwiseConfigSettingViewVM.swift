//
//  ReadwiseConfigSettingViewVM.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 26/06/2022.
//

import Foundation

class ReadwiseConfigSettingViewVM: ObservableObject {
    @Published private var auth_status_code: Int?
    
    var status_code: Int {
        if let auth_status_code = auth_status_code {
            return auth_status_code
        }
        return 1
    }
    
    func checkToken(token: String) async {
        do {
            let status_code = try await ReadwiseAPI().checkToken(token: token)
            
            DispatchQueue.main.async {
                self.auth_status_code = status_code
            }
        } catch {
            print("\(#function) error")
            
            DispatchQueue.main.async {
                self.auth_status_code = 1
            }
        }
    }
}
