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
	let url: URL
	
	init(url: URL, client: HTTPCLientProtocol) {
		self.url = url
		self.client = client
	}
	
	func load() {
		client.get(from: url)
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
		let url = URL(string: "http://a-given-url")!
		let client = HTTPClientSpy()
		let _ = RemoteFeedLoader(url: url, client: client)
		
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let url = URL(string: "http://a-given-url")!
		let client = HTTPClientSpy()
		let sut  = RemoteFeedLoader(url: url, client: client)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURL, url)
	}

}
