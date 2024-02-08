//
//  RemoteFeedLoaderTests.swift
//  RemoteFeedLoaderTests
//
//  Created by Henrique Batista on 07/02/24.
//

import XCTest
@testable import EssentialDeveloper

class RemoteFeedLoader {
	let client: HTTPCLientProtocol
	
	init(client: HTTPCLientProtocol) {
		self.client = client
	}
	
	func load() {
		client.get(from: URL(string: "htttp://a-url.com")!)
	}
}

protocol HTTPCLientProtocol {
	func get(from url: URL)
}

class HTTPClientSpy: HTTPCLientProtocol {
	func get(from url: URL) {
		requestedURL = url
	}
	
	var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotResquestDataFromURL() {
		let client = HTTPClientSpy()
		let _ = RemoteFeedLoader(client: client)
		
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let client = HTTPClientSpy()
		let sut  = RemoteFeedLoader(client: client)
		
		sut.load()
		
		XCTAssertNotNil(client.requestedURL)
	}

}
