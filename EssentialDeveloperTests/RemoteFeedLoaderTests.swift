//
//  RemoteFeedLoaderTests.swift
//  RemoteFeedLoaderTests
//
//  Created by Henrique Batista on 07/02/24.
//

import XCTest
@testable import EssentialDeveloper

class RemoteFeedLoader {
	func load() {
		HTTPCLient.shared.resquesteURL = URL(string: "htttp://a-url.com")
	}
}

class HTTPCLient {
	static let shared = HTTPCLient()
	
	private init() {}
	
	var resquesteURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotResquestDataFromURL() {
		let client = HTTPCLient.shared
		let _ = RemoteFeedLoader()
		
		XCTAssertNil(client.resquesteURL)
	}
	
	func test_load_requestDataFromURL() {
		let client = HTTPCLient.shared
		let sut  = RemoteFeedLoader()
		
		sut.load()
		
		XCTAssertNotNil(client.resquesteURL)
	}

}
