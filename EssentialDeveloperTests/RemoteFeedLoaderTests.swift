//
//  RemoteFeedLoaderTests.swift
//  RemoteFeedLoaderTests
//
//  Created by Henrique Batista on 07/02/24.
//

import XCTest
import EssentialDeveloper

final class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotResquestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "http://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "http://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversEoorOnClientError() {
		let (sut, client) = makeSUT()
		
		var capturedErrors = [RemoteFeedLoader.Error]()
		sut.load() { capturedErrors.append($0) }
		
		let clientError = NSError(domain: "Test Error", code: 0)
		client.completions[0](clientError)
		
		XCTAssertEqual(capturedErrors, [.connectivity])
	}
	
	//MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		
		return (sut, client)
	}
	
	private class HTTPClientSpy: HTTPCLientProtocol {
		var requestedURLs = [URL]()
		var completions = [(Error) -> Void]()
		
		func get(from url: URL, completion: @escaping (Error) -> Void) {
			completions.append(completion)
			requestedURLs.append(url)
		}
	}

}
