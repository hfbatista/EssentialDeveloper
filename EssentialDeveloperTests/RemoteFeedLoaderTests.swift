//
//  RemoteFeedLoaderTests.swift
//  RemoteFeedLoaderTests
//
//  Created by Henrique Batista on 07/02/24.
//

import XCTest
@testable import EssentialDeveloper

class RemoteFeedLoader {
	
}

class HTTPCLient {
	var resquesteURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotResquestDataFromURL() {
		let client = HTTPCLient()
		let _ = RemoteFeedLoader()
		
		XCTAssertNil(client.resquesteURL)
	}

}
