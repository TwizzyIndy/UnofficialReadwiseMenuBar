//
//  ReadwiseAPI_Tests.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import XCTest

@testable import UnofficialReadwiseMenuBar

class ReadwiseAPI_Test: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    override func setUp() async throws {
        
    }
    
    func test_checkToken()
    {
        let vm = HighlightViewVM()
        
        vm.checkToken(token: "jJ1ZJ0TaO6eqEtHc8ZGo2i1LhkiaujtDlu4hk3cGZiUjufQdxz")
    }
    
    func test_getHighlightList()
    {
        let vm = HighlightViewVM()

        vm.getHighlightList(token: "jJ1ZJ0TaO6eqEtHc8ZGo2i1LhkiaujtDlu4hk3cGZiUjufQdxz")
        
        print(vm.highlights)
    }
}
