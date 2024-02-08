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
		HTTPCLient.shared.get(from: URL(string: "htttp://a-url.com")!)
	}
}

class HTTPCLient {
	static var shared = HTTPCLient()
	func get(from url: URL){}
}

class HTTPClientSpy: HTTPCLient {
	override func get(from url: URL) {
		requestedURL = url
	}
	
	var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotResquestDataFromURL() {
		let client = HTTPClientSpy()
		HTTPCLient.shared = client
		let _ = RemoteFeedLoader()
		
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let client = HTTPClientSpy()
		HTTPCLient.shared = client
		let sut  = RemoteFeedLoader()
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}

}
