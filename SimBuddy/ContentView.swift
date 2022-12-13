//
//  ContentView.swift
//  SimBuddy
//
//  Created by Craig Hockenberry on 12/12/22.
//

import Cocoa

class ContentView: NSView {
	
	override func draw(_ dirtyRect: CGRect) {
		if let accentColor = NSColor(named: "AccentColor") {
			accentColor.withAlphaComponent(0.05).set()
			dirtyRect.fill()
		}
	}
}
