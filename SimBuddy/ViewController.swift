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

	@IBOutlet var bundleNameTextField: NSTextField!
	@IBOutlet var bundleIdentifierTextField: NSTextField!

	var selectedDeviceIndex = 0
	var selectedApplicationIndex = 0
	
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
			if devices.count > 0 {
				loadApplications()
			}
		}
	}

	func loadApplications() {
		if devices.count > 0 {
			Task {
				let selectedDeviceIdentifier = devices[selectedDeviceIndex].uniqueIdentifier
				self.applications = await Simulator.applications(for: selectedDeviceIdentifier).sorted(by: { firstApplication, secondApplication in
					firstApplication.name < secondApplication.name
				})
			}
		}
	}

	func updateView() {
		debugLog()

		do {
			let menu = NSMenu(title: "Devices")
			if devices.count == 0 {
				devicePopUpButton.isEnabled = false
				let menuItem = NSMenuItem(title: "No Devices", action: nil, keyEquivalent: "")
				menuItem.isEnabled = false
				menu.addItem(menuItem)
			}
			else {
				devicePopUpButton.isEnabled = true
				for (index, device) in devices.enumerated() {
					let menuItem = NSMenuItem(title: device.name, action: #selector(selectDevice), keyEquivalent: "")
					menuItem.tag = index
					menu.addItem(menuItem)
				}
			}
			devicePopUpButton.menu = menu
			devicePopUpButton.selectItem(at: selectedDeviceIndex)
		}
		
		do {
			let menu = NSMenu(title: "Applications")
			if applications.count == 0 {
				applicationPopUpButton.isEnabled = false
				let menuItem = NSMenuItem(title: "No Applications", action: nil, keyEquivalent: "")
				menuItem.isEnabled = false
				menu.addItem(menuItem)
			}
			else {
				applicationPopUpButton.isEnabled = true
				for (index, application) in applications.enumerated() {
					let menuItem = NSMenuItem(title: application.name, action: #selector(selectApplication), keyEquivalent: "")
					menuItem.tag = index
					menu.addItem(menuItem)
				}
			}
			applicationPopUpButton.menu = menu
			applicationPopUpButton.selectItem(at: selectedApplicationIndex)
		}
		
		if applications.count > 0 {
			let selectedApplication = applications[selectedApplicationIndex]
			bundleNameTextField.stringValue = selectedApplication.bundleName
			bundleIdentifierTextField.stringValue = selectedApplication.bundleIdentifier
		}
		else {
			bundleNameTextField.stringValue = "N/A"
			bundleIdentifierTextField.stringValue = "N/A"
		}
	}
	
	@objc
	func selectDevice(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let menuItem = sender as? NSMenuItem {
			let index = menuItem.tag
			let device = devices[index]
			debugLog("index = \(index), udid = \(device.udid)")
			selectedDeviceIndex = index
			loadApplications()
		}
	}

	@objc
	func selectApplication(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let menuItem = sender as? NSMenuItem {
			let index = menuItem.tag
			let application = applications[index]
			debugLog("index = \(index), type = \(application.type)")
			selectedApplicationIndex = index
			updateView()
		}
	}

	@objc
	func applicationDidBecomeActive(_ notification: NSNotification) {
		debugLog("notification = \(notification)")
		loadDevices()
		updateView()
	}
	
}

