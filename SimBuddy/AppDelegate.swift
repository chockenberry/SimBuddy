//
//  AppDelegate.swift
//  SimBuddy
//
//  Created by Craig Hockenberry on 12/9/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		
		/*
		//let openPanel = NSOpenPanel()
		//let response = openPanel.runModal()
		//if response == .OK {
		do {
			let tool = URL(fileURLWithPath: "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl")
			//tool.startAccessingSecurityScopedResource()
			launch(tool: tool, arguments: ["list", "devices", "-j"]) { error, data in
				print("error = \(error)")
				let object = try? JSONSerialization.jsonObject(with: data)
				//print("object = \(String(describing: object))")
				if let root = object as? Dictionary<String, Any> {
					if let simulators = root["devices"] as? Dictionary<String, Array<Any>> {
						for simulator in simulators {
							for device in simulator.value {
								if let device = device as? Dictionary<String, Any> {
									//print(String(describing: device))
									if let state = device["state"] as? String,
									   let name = device["name"] as? String,
									   let udid = device["udid"] as? String {
										if state == "Booted" {
											print("name = \(name), state = \(state), udid = \(udid)")
										}
									}
								}
							}
						}
					}
				}
				//let string = String(data: data, encoding: .utf8)
				//print("string = \(String(describing: string))")
				//tool.stopAccessingSecurityScopedResource()
			}
		}
		 */
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}

}

