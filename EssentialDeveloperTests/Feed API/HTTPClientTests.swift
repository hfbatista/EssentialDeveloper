//
//  HTTPClientTests.swift
//  EssentialDeveloperTests
//
//  Created by Henrique Batista on 10/02/24.
//

import XCTest

final class HTTPClientTests: XCTestCase {
	
	private class URLSessionHTTPClient {
		private let session: URLSession
		
		init(session: URLSession) {
			self.session = session
		}
		
		func get(from url: URL) {
			self.session.dataTask(with: url) { _,_,_ in }
		}
	}

	func test_getFromURL_createsDataTaskWithURL() {
		let url = URL(string: "http://a-url.com")!
		let session = URLSessionSpy()
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url)
		
		XCTAssertEqual(session.receivedURLs, [url])
	}
	
	//MARK: - Helpers
	
	private class URLSessionSpy: URLSession {
		var receivedURLs = [URL]()
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			receivedURLs.append(url)
			return FakeURLSessionDataTask()
		}
	}
	
	private class FakeURLSessionDataTask: URLSessionDataTask {}

}
