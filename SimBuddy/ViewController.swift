//
//  ViewController.swift
//  SimBuddy
//
//  Created by Craig Hockenberry on 12/9/22.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet var devicePopUpButton: NSPopUpButton!
	@IBOutlet var applicationPopUpButton: NSPopUpButton!

	var devices: [DeviceInfo] = [] {
		didSet {
			updateView()
		}
	}
	var applications: [ApplicationInfo] = [] {
		didSet {
			updateView()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		/*
		Simulator.devices { result in
			self.devices = result.filter({ deviceInfo in
				deviceInfo.isBooted
			}).sorted(by: { firstDeviceInfo, secondDeviceInfo in
				firstDeviceInfo.name < secondDeviceInfo.name
			})
		}
		*/
		//loadDevices()
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
			updateView()
		}
	}

	func loadDevices() {
		Task {
			self.devices = await Simulator.devices().filter({deviceInfo in
				deviceInfo.isBooted
			}).sorted(by: { firstDevice, secondDevice in
				firstDevice.name < secondDevice.name
			})
			loadApplications()
		}
	}

	func loadApplications() {
		Task {
			self.applications = await Simulator.applications(for: "A42D2B4A-F65D-4E73-A1D7-3B9D20FA6FA0").sorted(by: { firstApplication, secondApplication in
				firstApplication.name < secondApplication.name
			})
		}
	}

	func updateView() {
		debugLog()

		do {
			let menu = NSMenu(title: "Devices")
			for (index, device) in devices.enumerated() {
				let menuItem = NSMenuItem(title: device.name, action: #selector(selectDevice), keyEquivalent: "")
				menuItem.tag = index
				menu.addItem(menuItem)
			}
			devicePopUpButton.menu = menu
		}
		
		do {
			let menu = NSMenu(title: "Applications")
			for (index, application) in applications.enumerated() {
				let menuItem = NSMenuItem(title: application.name, action: #selector(selectApplication), keyEquivalent: "")
				menuItem.tag = index
				menu.addItem(menuItem)
			}
			applicationPopUpButton.menu = menu
		}
		
	}
	
	@objc
	func selectDevice(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let menuItem = sender as? NSMenuItem {
			let index = menuItem.tag
			let device = devices[index]
			debugLog("index = \(index), udid = \(device.udid)")
		}
	}

	@objc
	func selectApplication(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let menuItem = sender as? NSMenuItem {
			let index = menuItem.tag
			let application = applications[index]
			debugLog("index = \(index), type = \(application.type)")
		}
	}

	@objc
	func applicationDidBecomeActive(_ notification: NSNotification) {
		debugLog("notification = \(notification)")
		loadDevices()
		updateView()
	}
	
}

