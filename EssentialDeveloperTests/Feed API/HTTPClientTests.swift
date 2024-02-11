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
	
	struct UnexpectedErroWithNoValiues: Error {}
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _,_,error in
			if let error {
				completion(.failure(error))
			} else {
				completion(.failure(UnexpectedErroWithNoValiues()))
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
		let url = anyURL()
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
		let requestError: NSError? = NSError(domain: "any error", code: 1)
		let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
		
		XCTAssertEqual(receivedError?.domain, requestError?.domain)
		XCTAssertEqual(receivedError?.code, requestError?.code)
				
	}
	
	func test_getFromURL_failsOnAllNilValues() {
		XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
	}
	
	//MARK: - Helpers
	
	private func makeSTU(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
		let sut = URLSessionHTTPClient()
		trackForMemmoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func anyURL() -> URL {
		URL(string: "http://any-url.com")!
	}
	
	private func resultErrorFor(data: Data?, response: HTTPURLResponse?, error: Error?,file: StaticString = #filePath, line: UInt = #line) -> Error? {
		URLProtocolStub.stub(data: data, response: response, error: error)
		let sut = makeSTU(file: file, line: line)
		let exp = expectation(description: "Wait for completion")
		var receivedError: Error?
		
		sut.get(from: anyURL()) { result in
			switch result {
				case let .failure(error):
					receivedError = error
				default:
					XCTFail("Expected failure got \(result) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		return receivedError
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
