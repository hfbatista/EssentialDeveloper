//
//  XCTestCase+MemoryLeakTracker.swift
//  EssentialDeveloperTests
//
//  Created by Henrique Batista on 11/02/24.
//

import XCTest

extension XCTestCase {
	func trackForMemmoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance shoud've been dealocated. Potential memory leak", file: file, line: line)
		}
	}
}
