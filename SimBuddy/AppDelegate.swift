//
//  AppDelegate.swift
//  SimBuddy
//
//  Created by Craig Hockenberry on 12/9/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	var windowController: NSWindowController?
	
	let hasRunKey = "hasRun"

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let hasRun = UserDefaults.standard.bool(forKey: hasRunKey)
		if !hasRun {
			showHelpWindow(nil)
			UserDefaults.standard.set(true, forKey: hasRunKey)
		}
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
		return true
	}
	
	@IBAction
	func showHelpWindow(_ sender: Any?) {
		if windowController == nil {
			if let newWindowController = NSStoryboard.main?.instantiateController(withIdentifier: "helpWindowController") as? NSWindowController {
				newWindowController.loadWindow()
				windowController = newWindowController
			}
		}
		if let windowController {
			windowController.window?.makeKeyAndOrderFront(nil)
		}
	}
}

