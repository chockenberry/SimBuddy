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

	@IBOutlet var openBundleButton: NSButton!
	@IBOutlet var openDataButton: NSButton!

	var selectedDeviceIndex: Int?
	var selectedApplicationIndex: Int?
	
	let selectedDeviceIdentifierKey = "selectedDeviceIdentifier"
	let selectedApplicationIdentifierKey = "selectedApplicationIdentifier"

	var devices: [DeviceInfo] = []
	var applications: [ApplicationInfo] = []

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
			devices = await Simulator.devices().filter({deviceInfo in
				deviceInfo.isBooted
			}).sorted(by: { firstDevice, secondDevice in
				firstDevice.name < secondDevice.name
			})
			
			if devices.count > 0 {
				selectedDeviceIndex = 0

				if let selectedDeviceIdentifier = UserDefaults.standard.string(forKey: selectedDeviceIdentifierKey) {
					if let deviceIndex = devices.firstIndex(where: { deviceInfo in
						deviceInfo.uniqueIdentifier == selectedDeviceIdentifier
					}) {
						selectedDeviceIndex = deviceIndex
					}
				}
					
				loadApplications()
			}
			else {
				selectedDeviceIndex = nil
			}
			
			updateView()
		}
	}

	func loadApplications() {
		if devices.count > 0 {
			Task {
				let deviceIdentifier: String
				if let selectedDeviceIndex {
					deviceIdentifier = devices[selectedDeviceIndex].uniqueIdentifier
				}
				else {
					deviceIdentifier = devices.first!.uniqueIdentifier
				}
				applications = await Simulator.applications(for: deviceIdentifier).sorted(by: { firstApplication, secondApplication in
					firstApplication.name < secondApplication.name
				})
				
				if applications.count > 0 {
					selectedApplicationIndex = 0

					if let selectedApplicationIdentifier = UserDefaults.standard.string(forKey: selectedApplicationIdentifierKey) {
						if let applicationIndex = applications.firstIndex(where: { applicationInfo in
							applicationInfo.uniqueIdentifier == selectedApplicationIdentifier
						}) {
							selectedApplicationIndex = applicationIndex
						}
					}
				}
				else {
					selectedApplicationIndex = nil
				}
				
				updateView()
			}
		}
	}

	func updateView() {
		debugLog()

		do {
			let menu = NSMenu(title: "Devices")
			if devices.count == 0 {
				let menuItem = NSMenuItem(title: "No Devices", action: nil, keyEquivalent: "")
				menuItem.isEnabled = false
				menu.addItem(menuItem)
			}
			else {
				for (index, device) in devices.enumerated() {
					let menuItem = NSMenuItem(title: device.name, action: #selector(selectDevice), keyEquivalent: "")
					menuItem.tag = index
					menu.addItem(menuItem)
				}
			}
			
			devicePopUpButton.menu = menu
			if let selectedDeviceIndex {
				devicePopUpButton.isEnabled = true
				devicePopUpButton.selectItem(at: selectedDeviceIndex)
			}
			else {
				devicePopUpButton.isEnabled = false
				devicePopUpButton.selectItem(at: 0)
			}
		}
		
		do {
			let menu = NSMenu(title: "Applications")
			if applications.count == 0 {
				let menuItem = NSMenuItem(title: "No Applications", action: nil, keyEquivalent: "")
				menuItem.isEnabled = false
				menu.addItem(menuItem)
			}
			else {
				for (index, application) in applications.enumerated() {
					let menuItem = NSMenuItem(title: application.name, action: #selector(selectApplication), keyEquivalent: "")
					menuItem.tag = index
					menu.addItem(menuItem)
				}
			}
			
			applicationPopUpButton.menu = menu
			if let selectedApplicationIndex {
				applicationPopUpButton.isEnabled = true
				applicationPopUpButton.selectItem(at: selectedApplicationIndex)
			}
			else {
				applicationPopUpButton.isEnabled = false
				applicationPopUpButton.selectItem(at: 0)
			}
		}
		
		if let selectedApplicationIndex {
			let selectedApplication = applications[selectedApplicationIndex]
			bundleNameTextField.stringValue = selectedApplication.bundleName
			bundleIdentifierTextField.stringValue = selectedApplication.bundleIdentifier

			openBundleButton.isEnabled = true
			openDataButton.isEnabled = true
		}
		else {
			bundleNameTextField.stringValue = "N/A"
			bundleIdentifierTextField.stringValue = "N/A"

			openBundleButton.isEnabled = false
			openDataButton.isEnabled = false
		}
	}
	
	@objc
	func selectDevice(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let menuItem = sender as? NSMenuItem {
			let index = menuItem.tag
			let device = devices[index]
			debugLog("index = \(index), udid = \(device.udid)")
			UserDefaults.standard.set(device.uniqueIdentifier, forKey: selectedDeviceIdentifierKey)
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
			UserDefaults.standard.set(application.uniqueIdentifier, forKey: selectedApplicationIdentifierKey)
			selectedApplicationIndex = index
			updateView()
		}
	}

	@IBAction
	func openBundle(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let selectedApplicationIndex {
			let selectedApplication = applications[selectedApplicationIndex]
			let selectedURL: URL
			if #available(macOS 13.0, *) {
				selectedURL = selectedApplication.bundleURL.appending(path: "Info.plist", directoryHint: .notDirectory)
			} else {
				selectedURL = selectedApplication.bundleURL.appendingPathComponent("Info.plist")
			}
			NSWorkspace.shared.activateFileViewerSelecting([selectedURL])
		}
	}

	@IBAction
	func openData(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let selectedApplicationIndex {
			let selectedApplication = applications[selectedApplicationIndex]
			NSWorkspace.shared.open(selectedApplication.dataURL)
		}
	}

	@objc
	func applicationDidBecomeActive(_ notification: NSNotification) {
		debugLog("notification = \(notification)")
		loadDevices()
		updateView()
	}
	
}

