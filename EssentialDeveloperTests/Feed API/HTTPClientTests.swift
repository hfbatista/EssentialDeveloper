//
//  HTTPClientTests.swift
//  EssentialDeveloperTests
//
//  Created by Henrique Batista on 10/02/24.
//

import XCTest
import EssentialDeveloper

final class HTTPClientTests: XCTestCase {
	
	private class URLSessionHTTPClient {
		private let session: URLSession
		
		init(session: URLSession) {
			self.session = session
		}
		
		func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
			self.session.dataTask(with: url) { _,_,error in
				if let error {
//					completion(.failure(error))
				}
			}.resume()
		}
	}
	
	func test_getFromURL_resumesDataTaskWithURL() {
		let url = URL(string: "http://a-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url) { _ in }
		
		XCTAssertEqual(task.resumeCallsCount, 1)
	}
	
	func test_getFromURL_failsOnResquestError() {
		let url = URL(string: "http://a-url.com")!
		let session = URLSessionSpy()
		let error = NSError(domain: "any error", code: 1)
		session.stub(url: url, error: error)
		let sut = URLSessionHTTPClient(session: session)
		
		let exp = expectation(description: "Wait for completion")
		
		sut.get(from: url) { result in
			switch result {
				case let .failure(receivedError as NSError):
					XCTAssertEqual(receivedError, error)
				default:
					XCTFail("Expected error \(error) got \(result) instead")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	//MARK: - Helpers
	
	private class URLSessionSpy: URLSession {
		private var stubs = [URL : Stub]()
		
		private struct Stub {
			let task: URLSessionDataTask
			let error: Error?
		}
		
		func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
			stubs[url] = Stub(task: task, error: error)
		}
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			guard let stub = stubs[url] else {
				fatalError("could't find a stub for \(url)")
			}
			
			completionHandler(nil, nil, stub.error)
			return stub.task
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
