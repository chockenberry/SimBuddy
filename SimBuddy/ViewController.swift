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

	@IBOutlet var deviceUDIDTextField: NSTextField!
	@IBOutlet var bundleNameTextField: NSTextField!
	@IBOutlet var bundleIdentifierTextField: NSTextField!

	@IBOutlet var openBundleButton: NSButton!
	@IBOutlet var openDataButton: NSButton!
	@IBOutlet var openDocumentsButton: NSButton!
	@IBOutlet var openPreferencesButton: NSButton!
	@IBOutlet var openLocalFilesButton: NSButton!

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

	// MARK: -

	func loadDevices() {
		Task {
			devices = await Simulator.devices().filter({deviceInfo in
				deviceInfo.isBooted
			}).sorted(by: { firstDevice, secondDevice in
				firstDevice.name < secondDevice.name
			})

			loadApplications()
			
			updateView()
		}
	}

	func loadApplications() {
		if haveDevices {
			Task {
				let deviceIdentifier = devices[selectedDeviceIndex].uniqueIdentifier
				applications = await Simulator.applications(for: deviceIdentifier).sorted(by: { firstApplication, secondApplication in
					firstApplication.name < secondApplication.name
				})
				updateView()
			}
		}
		else {
			applications = []
			updateView()
		}
	}

	// MARK: -
	
	var haveDevices: Bool {
		return devices.count > 0
	}
	
	var selectedDeviceIndex: Int {
		if let selectedDeviceIdentifier = UserDefaults.standard.string(forKey: selectedDeviceIdentifierKey) {
			if let deviceIndex = devices.firstIndex(where: { deviceInfo in
				deviceInfo.uniqueIdentifier == selectedDeviceIdentifier
			})
			{
				return deviceIndex
			}
		}
		return 0
	}

	var selectedDevice: DeviceInfo {
		return devices[selectedDeviceIndex]
	}

	// MARK: -

	var haveApplications: Bool {
		return applications.count > 0
	}
	
	var selectedApplicationIndex: Int {
		if let selectedApplicationIdentifier = UserDefaults.standard.string(forKey: selectedApplicationIdentifierKey) {
			if let applicationIndex = applications.firstIndex(where: { applicationInfo in
				applicationInfo.uniqueIdentifier == selectedApplicationIdentifier
			}) {
				return applicationIndex
			}
		}
		return 0
	}

	var selectedApplication: ApplicationInfo {
		return applications[selectedApplicationIndex]
	}

	// MARK: -

	var haveGroupContainers: Bool {
		if haveApplications {
			return selectedApplication.groupContainers.count > 0
		}
		return false
	}

	var selectedGroupContainerIndex: Int {
		if let selectedGroupContainerIdentifier = UserDefaults.standard.string(forKey: selectedGroupContainerIdentifierKey) {
			if let groupContainerIndex = selectedApplication.groupContainers.firstIndex(where: { groupContainerInfo in
				groupContainerInfo.uniqueIdentifier == selectedGroupContainerIdentifier
			}) {
				return groupContainerIndex
			}
		}
		return 0
	}
	
	var selectedGroupContainer: GroupContainerInfo {
		return selectedApplication.groupContainers[selectedGroupContainerIndex]
	}
	
	// MARK: -

	func updateView() {
		debugLog()

		// update devices popup and menu
		do {
			let menu = NSMenu(title: "Devices")
			if haveDevices {
				for (index, device) in devices.enumerated() {
					let menuItem = NSMenuItem(title: device.name, action: #selector(selectDevice), keyEquivalent: "")
					menuItem.tag = index
					menu.addItem(menuItem)
				}
				
				devicePopUpButton.menu = menu
				devicePopUpButton.isEnabled = true
				devicePopUpButton.selectItem(at: selectedDeviceIndex)
			}
			else {
				let menuItem = NSMenuItem(title: "No Devices", action: nil, keyEquivalent: "")
				menuItem.isEnabled = false
				menu.addItem(menuItem)

				devicePopUpButton.menu = menu
				devicePopUpButton.isEnabled = false
				devicePopUpButton.selectItem(at: 0)
			}
		}
		
		// update applications popup and menu
		do {
			let menu = NSMenu(title: "Applications")
			if haveApplications {
				// add user applications, a separator, then system applications
				for (index, application) in applications.enumerated() {
					if application.type == "User" {
						let menuItem = NSMenuItem(title: application.name, action: #selector(selectApplication), keyEquivalent: "")
						menuItem.tag = index
						menu.addItem(menuItem)
					}
				}
				do {
					let menuItem = NSMenuItem.separator()
					menuItem.tag = -1
					menu.addItem(menuItem)
				}
				for (index, application) in applications.enumerated() {
					if application.type != "User" {
						let menuItem = NSMenuItem(title: application.name, action: #selector(selectApplication), keyEquivalent: "")
						menuItem.tag = index
						menu.addItem(menuItem)
					}
				}

				applicationPopUpButton.menu = menu
				applicationPopUpButton.isEnabled = true
				applicationPopUpButton.selectItem(withTag: selectedApplicationIndex)
			}
			else {
				let menuItem = NSMenuItem(title: "No Applications", action: nil, keyEquivalent: "")
				menuItem.isEnabled = false
				menu.addItem(menuItem)
				
				applicationPopUpButton.menu = menu
				applicationPopUpButton.isEnabled = false
				applicationPopUpButton.selectItem(at: 0)
			}
		}
		
		// update information and controls
		do {
			if haveDevices {
				deviceUDIDTextField.stringValue = selectedDevice.uniqueIdentifier
			}
			else {
				deviceUDIDTextField.stringValue = "No Device – Start one in the Simulator"
			}
			
			if haveApplications {
				bundleNameTextField.stringValue = selectedApplication.bundleName
				bundleIdentifierTextField.stringValue = selectedApplication.bundleIdentifier
			}
			else {
				bundleNameTextField.stringValue = ""
				bundleIdentifierTextField.stringValue = ""
			}
			
			let isEnabled = haveApplications
			openBundleButton.isEnabled = isEnabled
			openDataButton.isEnabled = isEnabled
			openDocumentsButton.isEnabled = isEnabled
			openPreferencesButton.isEnabled = isEnabled
			openLocalFilesButton.isEnabled = isEnabled
		}
		
		// update group containers popup and menu
		do {
			if haveApplications {
				let menu = NSMenu(title: "GroupContainers")
				if haveGroupContainers {
					for (index, groupContainer) in selectedApplication.groupContainers.enumerated() {
						let menuItem = NSMenuItem(title: groupContainer.identifier, action: #selector(selectGroupContainer), keyEquivalent: "")
						menuItem.tag = index
						menu.addItem(menuItem)
					}
					groupContainersPopUpButton.menu = menu
					groupContainersPopUpButton.isEnabled = true
					groupContainersPopUpButton.selectItem(at: selectedGroupContainerIndex)
					openGroupContainerButton.isEnabled = true
				}
				else {
					let menuItem = NSMenuItem(title: "No Group Containers", action: nil, keyEquivalent: "")
					menuItem.isEnabled = false
					menu.addItem(menuItem)
					groupContainersPopUpButton.menu = menu
					groupContainersPopUpButton.isEnabled = false
					groupContainersPopUpButton.selectItem(at: 0)
					openGroupContainerButton.isEnabled = false
				}
			}
			else {
				let menu = NSMenu(title: "GroupContainers")
				groupContainersPopUpButton.menu = menu
				groupContainersPopUpButton.isEnabled = false
				openGroupContainerButton.isEnabled = false
			}
		}
	}
	
	// MARK: -

	@objc
	func selectDevice(_ sender: Any) {
		debugLog("sender = \(sender)")
		if haveDevices {
			if let menuItem = sender as? NSMenuItem {
				let index = menuItem.tag
				let device = devices[index]
				debugLog("index = \(index), udid = \(device.udid)")
				UserDefaults.standard.set(device.uniqueIdentifier, forKey: selectedDeviceIdentifierKey)
				loadApplications()
			}
		}
	}

	@objc
	func selectApplication(_ sender: Any) {
		debugLog("sender = \(sender)")
		if haveApplications {
			if let menuItem = sender as? NSMenuItem {
				let index = menuItem.tag
				let application = applications[index]
				//debugLog("index = \(index), uniqueIdentifier = \(application.uniqueIdentifier)")
				UserDefaults.standard.set(application.uniqueIdentifier, forKey: selectedApplicationIdentifierKey)
				updateView()
			}
		}
	}

	@IBAction
	func selectGroupContainer(_ sender: Any) {
		debugLog("sender = \(sender)")
		if haveApplications {
			if let menuItem = sender as? NSMenuItem {
				let index = menuItem.tag
				let groupContainer = selectedApplication.groupContainers[index]
				//debugLog("index = \(index), containerURL = \(groupContainer.containerURL)")
				UserDefaults.standard.set(groupContainer.uniqueIdentifier, forKey: selectedGroupContainerIdentifierKey)
			}
		}
	}

	@IBAction
	func openBundle(_ sender: Any) {
		debugLog("sender = \(sender)")
		if haveApplications {
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
		NSWorkspace.shared.open(selectedApplication.dataURL)
	}

	@IBAction
	func openDocuments(_ sender: Any) {
		debugLog("sender = \(sender)")
		if haveApplications {
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
		if haveApplications {
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

		let filesApplicationIdentifier = "com.apple.DocumentsApp"
		if let applicationIndex = applications.firstIndex(where: { applicationInfo in
			applicationInfo.uniqueIdentifier == filesApplicationIdentifier
		}) {
			let filesApplication = applications[applicationIndex]
			let localStorageGroupContainerIdentifier = "group.com.apple.FileProvider.LocalStorage"
			if let groupContainerIndex = filesApplication.groupContainers.firstIndex(where: { groupContainerInfo in
				groupContainerInfo.uniqueIdentifier == localStorageGroupContainerIdentifier
			}) {
				let groupContainer = filesApplication.groupContainers[groupContainerIndex]
				let localFilesURL: URL
				if #available(macOS 13.0, *) {
					localFilesURL = groupContainer.containerURL.appending(path: "File Provider Storage", directoryHint: .isDirectory)
				} else {
					localFilesURL = groupContainer.containerURL.appendingPathComponent("File Provider Storage")
				}
				NSWorkspace.shared.open(localFilesURL)
			}
		}
	}

	@IBAction
	func openGroupContainer(_ sender: Any) {
		debugLog("sender = \(sender)")
		if haveApplications && haveGroupContainers {
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

