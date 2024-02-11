//
//  HTTPClientTests.swift
//  EssentialDeveloperTests
//
//  Created by Henrique Batista on 10/02/24.
//

import XCTest
import EssentialDeveloper

private class URLSessionHTTPClient {
	private let session: URLSession
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _,_,error in
			if let error {
				completion(.failure(error))
			}
		}.resume()
	}
}

final class HTTPClientTests: XCTestCase {
	
	override class func setUp() {
		URLProtocolStub.startInterceptingRequests()
	}
	
	override class func tearDown() {
		URLProtocolStub.stopInterceptingRequests()
	}
	
	func test_getFromURL_performGETRequestWithURL() {
		let url = URL(string: "http://a-given-url.com")!
		let exp = expectation(description: "Wait for request")
		
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}
		
		makeSTU().get(from: url) { _ in }
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_getFromURL_failsOnResquestError() {
		let url = URL(string: "http://a-url.com")!
		let requestError = NSError(domain: "any error", code: 1)
		URLProtocolStub.stub(data: nil, response: nil, error: requestError)
		let exp = expectation(description: "Wait for completion")
		
		makeSTU().get(from: url) { result in
			switch result {
				case let .failure(receivedError as NSError):
					XCTAssertEqual(receivedError.domain, requestError.domain)
					XCTAssertEqual(receivedError.code, requestError.code)
				default:
					XCTFail("Expected error \(requestError) got \(result) instead")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	//MARK: - Helpers
	
	private func makeSTU(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
		let sut = URLSessionHTTPClient()
		trackForMemmoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func trackForMemmoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance shoud've been dealocated. Potential memory leak", file: file, line: line)
		}
	}
	
	private class URLProtocolStub: URLProtocol {
		private static var stub: StubModel?
		private static var requestObserver: ((URLRequest) -> Void)?
		
		private struct StubModel {
			let data: Data?
			let response: HTTPURLResponse?
			let error: Error?
		}
		
		static func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
			stub = StubModel(data: data, response: response, error: error)
		}
		
		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stub = nil
			requestObserver = nil
		}
		
		static func observeRequests(observer: @escaping (URLRequest) -> Void) {
			requestObserver = observer
		}
		
		override class func canInit(with request: URLRequest) -> Bool {
			requestObserver?(request)
			return true
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			if let data = URLProtocolStub.stub?.data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			if let response = URLProtocolStub.stub?.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			
			if let error = URLProtocolStub.stub?.error {
				client?.urlProtocol(self, didFailWithError: error)
			}
			
			client?.urlProtocolDidFinishLoading(self)
		}
		
		override func stopLoading() {}
	}
}
