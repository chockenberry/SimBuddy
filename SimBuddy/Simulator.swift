//
//  Simulator.swift
//  SimBuddy
//
//  Created by Craig Hockenberry on 12/9/22.
//

import Foundation

/*
 /Applications/Xcode.app/Contents/Developer/usr/bin/simctl list devices -j
 
 {
   "devices" : {
      ...
	  "com.apple.CoreSimulator.SimRuntime.iOS-16-1" : [
		 {
		   "lastBootedAt" : "2022-12-07T23:42:38Z",
		   "dataPath" : "\/Users\/CHOCK\/Library\/Developer\/CoreSimulator\/Devices\/573D4A53-D1EC-48CA-A554-8DF7A94EFFBD\/data",
		   "dataPathSize" : 4834729984,
		   "logPath" : "\/Users\/CHOCK\/Library\/Logs\/CoreSimulator\/573D4A53-D1EC-48CA-A554-8DF7A94EFFBD",
		   "udid" : "573D4A53-D1EC-48CA-A554-8DF7A94EFFBD",
		   "isAvailable" : true,
		   "logPathSize" : 1110016,
		   "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-14",
		   "state" : "Booted",
		   "name" : "iPhone 14"
		 },
		 {
		   "dataPath" : "\/Users\/CHOCK\/Library\/Developer\/CoreSimulator\/Devices\/CB23E7F5-27DA-4290-9C1E-C641F0592BAF\/data",
		   "dataPathSize" : 13316096,
		   "logPath" : "\/Users\/CHOCK\/Library\/Logs\/CoreSimulator\/CB23E7F5-27DA-4290-9C1E-C641F0592BAF",
		   "udid" : "CB23E7F5-27DA-4290-9C1E-C641F0592BAF",
		   "isAvailable" : true,
		   "deviceTypeIdentifier" : "com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus",
		   "state" : "Shutdown",
		   "name" : "iPhone 14 Plus"
		 }
         ...
	   ]

 */

struct DeviceInfo {
	let name: String		// name
	let dataPath: String	// dataPath
	let isBooted: Bool		// state == "Booted"
	let udid: String		// udid
	
	var uniqueIdentifier: String {
		get {
			udid
		}
	}
}

/*
 /Applications/Xcode.app/Contents/Developer/usr/bin/simctl runtime list -j
 
 {
   "2B043A77-27EC-46F5-9E71-926519FB1DF8" : {
	 "build" : "20K67",
	 "deletable" : true,
	 "identifier" : "2B043A77-27EC-46F5-9E71-926519FB1DF8",
	 "kind" : "Disk Image",
	 "mountPath" : "\/Library\/Developer\/CoreSimulator\/Volumes\/tvOS_20K67",
	 "path" : "\/Library\/Developer\/CoreSimulator\/Images\/2B043A77-27EC-46F5-9E71-926519FB1DF8.dmg",
	 "platformIdentifier" : "com.apple.platform.appletvsimulator",
	 "runtimeBundlePath" : "\/Library\/Developer\/CoreSimulator\/Volumes\/tvOS_20K67\/Library\/Developer\/CoreSimulator\/Profiles\/Runtimes\/tvOS 16.1.simruntime
 ",
	 "runtimeIdentifier" : "com.apple.CoreSimulator.SimRuntime.tvOS-16-1",
	 "signatureState" : "Verified",
	 "sizeBytes" : 3363890340,
	 "state" : "Ready",
	 "version" : "16.1"
   },
   "03F43412-C224-4BE7-82FB-D7EF8384F91A" : {
	 "build" : "20B72",
	 "deletable" : false,
	 "identifier" : "03F43412-C224-4BE7-82FB-D7EF8384F91A",
	 "kind" : "Bundled with Xcode",
	 "path" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/iPhoneOS.platform\/Library\/Developer\/CoreSimulator\/Profiles\/Runtimes\/iOS.simruntime",
	 "platformIdentifier" : "com.apple.platform.iphonesimulator",
	 "runtimeBundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/iPhoneOS.platform\/Library\/Developer\/CoreSimulator\/Profiles\/Runtimes\/iOS.simruntime",
	 "runtimeIdentifier" : "com.apple.CoreSimulator.SimRuntime.iOS-16-1",
	 "signatureState" : "Unknown",
	 "sizeBytes" : 3883925504,
	 "state" : "Ready",
	 "version" : "16.1"
   },

 */

/*
	xcrun simctl listapps A42D2B4A-F65D-4E73-A1D7-3B9D20FA6FA0 > /tmp/output
	plutil -convert json /tmp/output -e json
	jsonify /tmp/output.json

 "com.iconfactory.Graphite" : {
	"ApplicationType" : "User",
	"Bundle" : "file:///Users/CHOCK/Library/Developer/CoreSimulator/Devices/A42D2B4A-F65D-4E73-A1D7-3B9D20FA6FA0/data/Containers/Bundle/Application/BC037B58-1CA1-4CEA-8908-05D468DDEC0C/Linea%20Sketch.app/",
	"BundleContainer" : "file:///Users/CHOCK/Library/Developer/CoreSimulator/Devices/A42D2B4A-F65D-4E73-A1D7-3B9D20FA6FA0/data/Containers/Bundle/Application/BC037B58-1CA1-4CEA-8908-05D468DDEC0C/",
	"CFBundleDisplayName" : "Linea Sketch",
	"CFBundleExecutable" : "Linea Sketch",
	"CFBundleIdentifier" : "com.iconfactory.Graphite",
	"CFBundleName" : "Linea Sketch",
	"CFBundleVersion" : "756",
	"DataContainer" : "file:///Users/CHOCK/Library/Developer/CoreSimulator/Devices/A42D2B4A-F65D-4E73-A1D7-3B9D20FA6FA0/data/Containers/Data/Application/713638FE-022B-444D-83A8-AF50E2F032A3/",
	"GroupContainers" : {
	   "group.com.iconfactory.Graphite" : "file:///Users/CHOCK/Library/Developer/CoreSimulator/Devices/A42D2B4A-F65D-4E73-A1D7-3B9D20FA6FA0/data/Containers/Shared/AppGroup/DE8B3264-DCC6-488B-9DC2-EB76D8B46985/"
	},
	"Path" : "/Users/CHOCK/Library/Developer/CoreSimulator/Devices/A42D2B4A-F65D-4E73-A1D7-3B9D20FA6FA0/data/Containers/Bundle/Application/BC037B58-1CA1-4CEA-8908-05D468DDEC0C/Linea Sketch.app",
	"SBAppTags" : []
 },

 */

struct ApplicationInfo {
	let name: String				// CFBundleDisplayName
	let type: String				// ApplicationType
	let bundleURL: URL				// Bundle
	let bundleIdentifier: String	// CFBundleIdentifier
	let bundleName: String			// CFBundleName
	let dataURL: URL				// DataContainer
	
	let groupContainers: [GroupContainerInfo]
	
	var uniqueIdentifier: String {
		get {
			bundleIdentifier
		}
	}
}

struct GroupContainerInfo {
	let identifier: String			// key
	let containerURL: URL			// value
	
	var uniqueIdentifier: String {
		get {
			identifier
		}
	}
}

class Simulator {
	
	static let plutilURL = URL(fileURLWithPath: "/usr/bin/plutil")
	static let xcrunURL = URL(fileURLWithPath: "/usr/bin/xcrun")

	static func applications(for udid: String) async -> [ApplicationInfo] {
		var result: [ApplicationInfo] = []
		
		do {
			let executableURL = xcrunURL
			let arguments = ["simctl", "listapps", udid]
			let applicationData = try await Process.launch(executableURL: executableURL, arguments: arguments)
			do {
				let executableURL = plutilURL
				let arguments = ["-convert", "json", "-o", "-", "--", "-"] // do you like a dash of dash with your arguments?
				let data = try await Process.launch(executableURL: executableURL, arguments: arguments, input: applicationData)
				let object = try? JSONSerialization.jsonObject(with: data)
				if let root = object as? Dictionary<String, Any> {
					for item in root {
						if let application = item.value as? Dictionary<String, Any> {
							if let name = application["CFBundleDisplayName"] as? String,
							   let type = application["ApplicationType"] as? String,
							   let bundlePath = application["Bundle"] as? String,
							   let bundleIdentifier = application["CFBundleIdentifier"] as? String,
							   let bundleName = application["CFBundleName"] as? String,
							   let dataPath = application["DataContainer"] as? String
							{
								if let bundleURL = URL(string: bundlePath),
								   let dataURL = URL(string: dataPath)
								{
									var groupContainers: [GroupContainerInfo] = []
									if let containers = application["GroupContainers"] as? Dictionary<String, Any> {
										for container in containers {
											let identifier = container.key
											if let containerPath = container.value as? String,
											   let containerURL = URL(string: containerPath)
											{
												let groupContainerInfo = GroupContainerInfo(identifier: identifier, containerURL: containerURL)
												groupContainers.append(groupContainerInfo)
											}
										}
									}
									let applicationInfo = ApplicationInfo(name: name, type: type, bundleURL: bundleURL, bundleIdentifier: bundleIdentifier, bundleName: bundleName, dataURL: dataURL, groupContainers: groupContainers)
									result.append(applicationInfo)
								}
							}
						}
					}
				}

			}
		}
		catch {
			debugLog("error: \(error.localizedDescription)")
		}

		return result
	}
	
	static func devices() async -> [DeviceInfo] {
		var result: [DeviceInfo] = []
		
		do {
			let executableURL = xcrunURL
			let arguments = ["simctl", "list", "devices", "-j"]
			let data = try await Process.launch(executableURL: executableURL, arguments: arguments)
			
			let object = try? JSONSerialization.jsonObject(with: data)
			if let root = object as? Dictionary<String, Any> {
				if let simulators = root["devices"] as? Dictionary<String, Array<Any>> {
					for simulator in simulators {
						for device in simulator.value {
							if let device = device as? Dictionary<String, Any> {
								if let name = device["name"] as? String,
								   let dataPath = device["dataPath"] as? String,
								   let state = device["state"] as? String,
								   let udid = device["udid"] as? String
								{
									let deviceInfo = DeviceInfo(name: name, dataPath: dataPath, isBooted: state == "Booted", udid: udid)
									result.append(deviceInfo)
								}
							}
						}
					}
				}
			}
		}
		catch {
			debugLog("error: \(error.localizedDescription)")
		}
		
		return result
		
		/* This could work in a sandbox, but would require getting a security-scoped bookmark for Xcode and tolerating a bunch of console spew:
		 
			xcodeURL.startAccessingSecurityScopedResource()

			let executableURL = simctlURL
			let arguments = ["list", "devices", "-j"]
			let data = try await Process.launch(executableURL: executableURL, arguments: arguments)

			xcodeURL.stopAccessingSecurityScopedResource()
		 */
	}
	
}

extension Process {
	
	/// Quinn's code with async/await support
	///
	/// - Parameters:
	///   - executableURL: The tool to run.
	///   - arguments: The command-line arguments to pass to that tool; defaults to the empty array.
	///   - input: Data to pass to the tool’s `stdin`; defaults to empty.
	/// - Returns:
	///   - Data from `stdout`
	
	// Adapted from: https://wwdcbysundell.com/2021/wrapping-completion-handlers-into-async-apis/

	@MainActor
	static func launch(executableURL: URL, arguments: [String] = [], input: Data = Data()) async throws -> Data {
		return try await withCheckedThrowingContinuation { continuation in
			launch(executableURL: executableURL, arguments: arguments, input: input) { result, output in
				switch result {
				case .success(_):
					continuation.resume(returning: output)
				case .failure(let error):
					continuation.resume(throwing: error)
				}
			}
		}
	}

	
	// The following code by Quinn is from the Developer Forums: https://developer.apple.com/forums/thread/690310

	/// Runs the specified tool as a child process, supplying `stdin` and capturing `stdout`.
	///
	/// - important: Must be run on the main queue.
	///
	/// - Parameters:
	///   - executableURL: The tool to run.
	///   - arguments: The command-line arguments to pass to that tool; defaults to the empty array.
	///   - input: Data to pass to the tool’s `stdin`; defaults to empty.
	///   - completionHandler: Called on the main queue when the tool has terminated.
	
	static func launch(executableURL: URL, arguments: [String] = [], input: Data = Data(), completionHandler: @escaping CompletionHandler) {
		// This precondition is important; read the comment near the `run()` call to
		// understand why.
		dispatchPrecondition(condition: .onQueue(.main))
		
		let group = DispatchGroup()
		let inputPipe = Pipe()
		let outputPipe = Pipe()
		
		var errorQ: Error? = nil
		var output = Data()
		
		let proc = Process()
		proc.executableURL = executableURL
		proc.arguments = arguments
		proc.standardInput = inputPipe
		proc.standardOutput = outputPipe
		group.enter()
		proc.terminationHandler = { _ in
			// This bounce to the main queue is important; read the comment near the
			// `run()` call to understand why.
			DispatchQueue.main.async {
				group.leave()
			}
		}
		
		// This runs the supplied block when all three events have completed (task
		// termination and the end of both I/O channels).
		//
		// - important: If the process was never launched, requesting its
		// termination status raises an Objective-C exception (ouch!).  So, we only
		// read `terminationStatus` if `errorQ` is `nil`.
		
		group.notify(queue: .main) {
			if let error = errorQ {
				completionHandler(.failure(error), output)
			} else {
				completionHandler(.success(proc.terminationStatus), output)
			}
		}
		
		do {
			func posixErr(_ error: Int32) -> Error { NSError(domain: NSPOSIXErrorDomain, code: Int(error), userInfo: nil) }
			
			// If you write to a pipe whose remote end has closed, the OS raises a
			// `SIGPIPE` signal whose default disposition is to terminate your
			// process.  Helpful!  `F_SETNOSIGPIPE` disables that feature, causing
			// the write to fail with `EPIPE` instead.
			
			let fcntlResult = fcntl(inputPipe.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1)
			guard fcntlResult >= 0 else { throw posixErr(errno) }
			
			// Actually run the process.
			
			try proc.run()
			
			// At this point the termination handler could run and leave the group
			// before we have a chance to enter the group for each of the I/O
			// handlers.  I avoid this problem by having the termination handler
			// dispatch to the main thread.  We are running on the main thread, so
			// the termination handler can’t run until we return, at which point we
			// have already entered the group for each of the I/O handlers.
			//
			// An alternative design would be to enter the group at the top of this
			// block and then leave it in the error hander.  I decided on this
			// design because it has the added benefit of all my code running on the
			// main queue and thus I can access shared mutable state, like `errorQ`,
			// without worrying about thread safety.
			
			// Enter the group and then set up a Dispatch I/O channel to write our
			// data to the child’s `stdin`.  When that’s done, record any error and
			// leave the group.
			//
			// Note that we ignore the residual value passed to the
			// `write(offset:data:queue:ioHandler:)` completion handler.  Earlier
			// versions of this code passed it along to our completion handler but
			// the reality is that it’s not very useful. The pipe buffer is big
			// enough that it usually soaks up all our data, so the residual is a
			// very poor indication of how much data was actually read by the
			// client.
			
			group.enter()
			let writeIO = DispatchIO(type: .stream, fileDescriptor: inputPipe.fileHandleForWriting.fileDescriptor, queue: .main) { _ in
				// `FileHandle` will automatically close the underlying file
				// descriptor when you release the last reference to it.  By holidng
				// on to `inputPipe` until here, we ensure that doesn’t happen. And
				// as we have to hold a reference anyway, we might as well close it
				// explicitly.
				//
				// We apply the same logic to `readIO` below.
				try! inputPipe.fileHandleForWriting.close()
			}
			let inputDD = input.withUnsafeBytes { DispatchData(bytes: $0) }
			writeIO.write(offset: 0, data: inputDD, queue: .main) { isDone, _, error in
				if isDone || error != 0 {
					writeIO.close()
					if errorQ == nil && error != 0 { errorQ = posixErr(error) }
					group.leave()
				}
			}
			
			// Enter the group and then set up a Dispatch I/O channel to read data
			// from the child’s `stdin`.  When that’s done, record any error and
			// leave the group.
			
			group.enter()
			let readIO = DispatchIO(type: .stream, fileDescriptor: outputPipe.fileHandleForReading.fileDescriptor, queue: .main) { _ in
				try! outputPipe.fileHandleForReading.close()
			}
			readIO.read(offset: 0, length: .max, queue: .main) { isDone, chunkQ, error in
				output.append(contentsOf: chunkQ ?? .empty)
				if isDone || error != 0 {
					readIO.close()
					if errorQ == nil && error != 0 { errorQ = posixErr(error) }
					group.leave()
				}
			}
		} catch {
			// If either the `fcntl` or the `run()` call threw, we set the error
			// and manually call the termination handler.  Note that we’ve only
			// entered the group once at this point, so the single leave done by the
			// termination handler is enough to run the notify block and call the
			// client’s completion handler.
			errorQ = error
			proc.terminationHandler!(proc)
		}
	}
	
	/// Called when the tool has terminated.
	///
	/// This must be run on the main queue.
	///
	/// - Parameters:
	///   - result: Either the tool’s termination status or, if something went
	///   wrong, an error indicating what that was.
	///   - output: Data captured from the tool’s `stdout`.
	
	typealias CompletionHandler = (_ result: Result<Int32, Error>, _ output: Data) -> Void

}
