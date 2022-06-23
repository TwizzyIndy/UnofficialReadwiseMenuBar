//
//  HighlightViewVM.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import Foundation

class HighlightViewVM: ObservableObject {
    
    @Published private var auth_status_code: Int?
    @Published private var hightlight_list: HighlightListModel?
    
    var highlighted_text: String {
        guard let p = hightlight_list?.results.randomElement()?.text else {
            return "N/A"
        }
        return p
    }
    
    
    func checkToken(token: String) {
        ReadwiseAPI().checkToken(token: token) { result in
            switch result {
            case .success(let status_code):
                if status_code == 0 {
                    DispatchQueue.main.async {
                        print("ok")
                        self.auth_status_code = status_code
                    }
                } else {
                    print("invalid status code")
                }
            case .failure(_):
                print("error")
            }
        }
    }
    
    func getHighlightList(token: String)
    {
        ReadwiseAPI().getHighlightsList(token: token) { result in
            switch result {
            case .success(let p):
                DispatchQueue.main.async {
                    self.hightlight_list = p
                }
            case .failure(_ ):
                print("error")
            }
        }
    }
}
