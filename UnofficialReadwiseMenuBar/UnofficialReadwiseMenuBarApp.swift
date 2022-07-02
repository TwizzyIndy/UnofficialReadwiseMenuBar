//
//  UnofficialReadwiseMenuBarApp.swift
//  UnofficialReadwiseMenuBar
//
//  Created by Aung Khant M. on 23/06/2022.
//

import SwiftUI

@main
struct UnofficialReadwiseMenuBarApp: App {
    let persistenceController = PersistenceController.shared
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    
    // The NSStatusBar manages a collection of status items displayed within a system-wide menu bar.
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private var popOver: NSPopover!
    
    let persistenceController = PersistenceController.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        statusBarItem.button?.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)
        statusBarItem.button?.imagePosition = .imageLeading
        // statusBarItem.menu = menu.build()
        statusBarItem.button?.action = #selector(togglePopOver)
        
        // set up popover
        self.popOver = NSPopover()
        self.popOver.contentSize = NSSize(width: 400, height: 200)
        self.popOver.behavior = .transient
        self.popOver.contentViewController = NSHostingController(rootView: HighlightView(context: persistenceController.container.viewContext).environment(\.managedObjectContext, persistenceController.container.viewContext))
    }
    
    @objc func togglePopOver() {
        
        if let button = statusBarItem.button {
            if popOver.isShown {
                self.popOver.performClose(nil)
            } else {
                self.popOver.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
