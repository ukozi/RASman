//
//  Controller.swift
//  RASman
//
//  Created by Lucas J. Chumley on 8/16/24.
//

import Cocoa
import SwiftUI

class CustomAboutWindowController: NSWindowController {

    convenience init() {
        let customAboutView = NSHostingController(rootView: CustomAboutView())
        let window = NSWindow(contentViewController: customAboutView)
        window.title = "About"
        self.init(window: window)
        window.styleMask.remove(.resizable)
        window.center()
    }
}
