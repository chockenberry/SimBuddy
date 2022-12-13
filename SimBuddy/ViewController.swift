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
	@IBOutlet var groupContainersPopUpButton: NSPopUpButton!
	@IBOutlet var openGroupContainerButton: NSButton!

	@IBOutlet var bundleNameTextField: NSTextField!
	@IBOutlet var bundleIdentifierTextField: NSTextField!

	@IBOutlet var openBundleButton: NSButton!
	@IBOutlet var openDataButton: NSButton!

	var selectedDeviceIndex: Int?
	var selectedApplicationIndex: Int?
	var selectedGroupContainerIndex: Int?

	let selectedDeviceIdentifierKey = "selectedDeviceIdentifier"
	let selectedApplicationIdentifierKey = "selectedApplicationIdentifier"
	let selectedGroupContainerIdentifierKey = "selectedGroupContainerIdentifier"

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
					selectedGroupContainerIndex	= 0
					
					if let selectedApplicationIdentifier = UserDefaults.standard.string(forKey: selectedApplicationIdentifierKey) {
						if let applicationIndex = applications.firstIndex(where: { applicationInfo in
							applicationInfo.uniqueIdentifier == selectedApplicationIdentifier
						}) {
							selectedApplicationIndex = applicationIndex
						}
						
						if let selectedGroupContainerIdentifier = UserDefaults.standard.string(forKey: selectedGroupContainerIdentifierKey) {
							let application = applications[selectedApplicationIndex!]
							if let groupContainerIndex = application.groupContainers.firstIndex(where: { groupContainerInfo in
								groupContainerInfo.uniqueIdentifier == selectedGroupContainerIdentifier
							}) {
								selectedGroupContainerIndex = groupContainerIndex
							}
						}
					}
				}
				else {
					selectedApplicationIndex = nil
					selectedGroupContainerIndex = nil
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

				let selectedApplication = applications[selectedApplicationIndex]
				bundleNameTextField.stringValue = selectedApplication.bundleName
				bundleIdentifierTextField.stringValue = selectedApplication.bundleIdentifier

				do {
					let menu = NSMenu(title: "GroupContainers")
					if selectedApplication.groupContainers.count > 0 {
						for (index, groupContainer) in selectedApplication.groupContainers.enumerated() {
							let menuItem = NSMenuItem(title: groupContainer.identifier, action: #selector(selectGroupContainer), keyEquivalent: "")
							menuItem.tag = index
							menu.addItem(menuItem)
						}
					}
					else {
						let menuItem = NSMenuItem(title: "No Group Containers", action: nil, keyEquivalent: "")
						menuItem.isEnabled = false
						menu.addItem(menuItem)
					}
					groupContainersPopUpButton.menu = menu
				}

				if let selectedGroupContainerIndex {
					groupContainersPopUpButton.isEnabled = true
					groupContainersPopUpButton.selectItem(at: selectedGroupContainerIndex)
				}
				else {
					groupContainersPopUpButton.isEnabled = false
					groupContainersPopUpButton.selectItem(at: 0)
				}
				
				openBundleButton.isEnabled = true
				openDataButton.isEnabled = true
			}
			else {
				applicationPopUpButton.isEnabled = false
				applicationPopUpButton.selectItem(at: 0)

				bundleNameTextField.stringValue = "No Application"
				bundleIdentifierTextField.stringValue = "No Application"

				do {
					let menu = NSMenu(title: "GroupContainers")
					let menuItem = NSMenuItem(title: "No Group Containers", action: nil, keyEquivalent: "")
					menuItem.isEnabled = false
					menu.addItem(menuItem)
					groupContainersPopUpButton.menu = menu
				}

				groupContainersPopUpButton.isEnabled = false
				groupContainersPopUpButton.selectItem(at: 0)

				openBundleButton.isEnabled = false
				openDataButton.isEnabled = false
			}
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
	func selectGroupContainer(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let menuItem = sender as? NSMenuItem {
			let index = menuItem.tag
			if let selectedApplicationIndex {
				let selectedApplication = applications[selectedApplicationIndex]
				let groupContainer = selectedApplication.groupContainers[index]
				debugLog("index = \(index), containerURL = \(groupContainer.containerURL)")
				UserDefaults.standard.set(groupContainer.uniqueIdentifier, forKey: selectedGroupContainerIdentifierKey)
				selectedGroupContainerIndex = index
			}
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

	@IBAction
	func openDocuments(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let selectedApplicationIndex {
			let selectedApplication = applications[selectedApplicationIndex]
			let documentsURL: URL
			if #available(macOS 13.0, *) {
				documentsURL = selectedApplication.dataURL.appending(path: "Documents", directoryHint: .isDirectory)
			} else {
				documentsURL = selectedApplication.dataURL.appendingPathComponent("Documents")
			}
			NSWorkspace.shared.open(documentsURL)
		}
	}

	@IBAction
	func openPreferences(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let selectedApplicationIndex {
			let selectedApplication = applications[selectedApplicationIndex]
			let preferencesURL: URL
			if #available(macOS 13.0, *) {
				preferencesURL = selectedApplication.dataURL.appending(path: "Library/Preferences", directoryHint: .isDirectory)
			} else {
				preferencesURL = selectedApplication.dataURL.appendingPathComponent("Library/Preferences")
			}
			NSWorkspace.shared.open(preferencesURL)
		}
	}

	@IBAction
	func openLocalFiles(_ sender: Any) {
		debugLog("sender = \(sender)")
//		if let selectedApplicationIndex {
//			let selectedApplication = applications[selectedApplicationIndex]
//			NSWorkspace.shared.open(selectedApplication.dataURL)
//		}
	}

	@IBAction
	func openGroupContainer(_ sender: Any) {
		debugLog("sender = \(sender)")
		if let selectedApplicationIndex,
			let selectedGroupContainerIndex
		{
			let selectedApplication = applications[selectedApplicationIndex]
			let selectedGroupContainer = selectedApplication.groupContainers[selectedGroupContainerIndex]
			NSWorkspace.shared.open(selectedGroupContainer.containerURL)
		}
	}

	@objc
	func applicationDidBecomeActive(_ notification: NSNotification) {
		debugLog("notification = \(notification)")
		loadDevices()
		updateView()
	}
	
}

