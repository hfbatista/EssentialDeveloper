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
	func test_getFromURL_failsOnResquestError() {
		URLProtocolStub.startInterceptingRequests()
		let url = URL(string: "http://a-url.com")!
		let requestError = NSError(domain: "any error", code: 1)
		URLProtocolStub.stub(url: url, error: requestError)
		let sut = URLSessionHTTPClient()
		
		let exp = expectation(description: "Wait for completion")
		
		sut.get(from: url) { result in
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
		URLProtocolStub.stopInterceptingRequests()
	}
	
	//MARK: - Helpers
	
	private class URLProtocolStub: URLProtocol {
		private static var stubs = [URL : StubModel]()
		
		private struct StubModel {
			let error: Error?
		}
		
		static func stub(url: URL, error: Error? = nil) {
			stubs[url] = StubModel(error: error)
		}
		
		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
		}
		
		
		override class func canInit(with request: URLRequest) -> Bool {
			guard let url = request.url else { return false }
			
			return URLProtocolStub.stubs[url] != nil
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
			
			if let error = stub.error {
				client?.urlProtocol(self, didFailWithError: error)
			}
			
			client?.urlProtocolDidFinishLoading(self)
		}
		
		override func stopLoading() {}
	}
}
