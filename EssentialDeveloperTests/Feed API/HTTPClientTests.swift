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
			self.session.dataTask(with: url) { _,_,_ in }.resume()
		}
	}

	func test_getFromURL_createsDataTaskWithURL() {
		let url = URL(string: "http://a-url.com")!
		let session = URLSessionSpy()
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url)
		
		XCTAssertEqual(session.receivedURLs, [url])
	}
	
	func test_getFromURL_resumesDataTaskWithURL() {
		let url = URL(string: "http://a-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url)
		
		XCTAssertEqual(task.resumeCallsCount, 1)
	}
	
	//MARK: - Helpers
	
	private class URLSessionSpy: URLSession {
		var receivedURLs = [URL]()
		private var stubs = [URL : URLSessionDataTask]()
		
		func stub(url: URL, task: URLSessionDataTask) {
			stubs[url] = task
		}
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			receivedURLs.append(url)
			return stubs[url] ?? FakeURLSessionDataTask()
		}
	}
	
	private class FakeURLSessionDataTask: URLSessionDataTask {
		override func resume() {}
	}
	private class URLSessionDataTaskSpy: URLSessionDataTask {
		var resumeCallsCount = 0
		
		override func resume() {
			resumeCallsCount += 1
		}
	}

}
