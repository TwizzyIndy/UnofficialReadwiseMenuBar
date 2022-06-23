//
//  MainMenu.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import Cocoa
import SwiftUI

class MainMenu: NSObject {
    // a new menu instance to add items
    let menu = NSMenu()    
    
    // function called by UnofficialReadwiseMenuBarApp to create the menu
    func build() -> NSMenu {
        
        let highlightView = HighlightView()
        let contentView = NSHostingController(rootView: highlightView)
        contentView.view.frame.size = CGSize(width: 300, height: 300)
        
        let customMenuItem = NSMenuItem()
        customMenuItem.view = contentView.view
        menu.addItem(customMenuItem)
        
        // separator here
        menu.addItem(NSMenuItem.separator())
        
        // quit menu item
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitMenuItem.target = self
        
        menu.addItem(quitMenuItem)
        
        return menu
    }
    
    // The selector that quits the app
    @objc func quit(sender: NSMenuItem) {
        NSApp.terminate(self)
    }
}
