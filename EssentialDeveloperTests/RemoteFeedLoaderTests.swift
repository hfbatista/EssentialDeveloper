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
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "http://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversEoorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.connectivity)) {
			let clientError = NSError(domain: "Test Error", code: 0)
			client.complete(with: clientError)
		}
		
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()

		let sampleCodes = [199, 201, 300, 400, 500]
		sampleCodes.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(.invalidData)) {
				let data = makeJSONItems([])
				client.complete(withStatusCode: code, data: data, at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.invalidData)) {
			let invalidJSON = Data("invalid Json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		}
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .success([])) {
			let emptyData = makeJSONItems([])
			client.complete(withStatusCode: 200, data: emptyData)
		}
	}
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let firstItem = makeItem(id: UUID(),
								 imageURL: URL(string: "htttp://a-url.com")!)
		
		let secondItem = makeItem(id: UUID(),
								  description: "A description",
								  location: "A location",
								  imageURL: URL(string: "htttp://a-url.com")!)
		
		let items = [firstItem.json, secondItem.json]
		
		expect(sut, toCompleteWith: .success([firstItem.model, secondItem.model])) {
			client.complete(withStatusCode: 200, data: makeJSONItems(items))
		}
	}
	
	func test_load_doesNotDeliversResultAfterSUTHasBeenDealocated() {
		let url = URL(string: "https://any-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
		
		var capturedResults = [RemoteFeedLoader.Result]()
		sut?.load() { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeJSONItems([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	//MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		
		trackForMemmoryLeaks(sut, file: file, line: line)
		trackForMemmoryLeaks(client, file: file, line: line)
		
		return (sut, client)
	}
	
	private func trackForMemmoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance shoud've been dealocated. Potential memory leak", file: file, line: line)
		}
	}
	
	private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItemModel, json: [String:Any]) {
		let item = FeedItemModel(id: id,
								 description: description,
								 location: location,
								 imageURL: imageURL)
		
		let json = ["id": item.id.uuidString,
					"description": item.description,
					"location": item.location,
					"image": item.imageURL.absoluteString].compactMapValues { $0 }
		
		return (item, json)
	}
	
	private func makeJSONItems(_ items: [[String:Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		
		var capturedResults = [RemoteFeedLoader.Result]()
		sut.load() { capturedResults.append($0) }
		
		action()
		
		XCTAssertEqual(capturedResults, [result], file: file, line: line)
	}
	
	private class HTTPClientSpy: HTTPCLientProtocol {
		private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
		var requestedURLs: [URL] {
			messages.map({ $0.url })
		}
		
		func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
			messages.append((url, completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
			let response = HTTPURLResponse(url: requestedURLs[index],
										   statusCode: code,
										   httpVersion: nil,
										   headerFields: nil)!
			
			messages[index].completion(.success(data, response))
		}
	}

}
