//
//  EssentialDeveloperAPIEntToEndTests.swift
//  EssentialDeveloperAPIEntToEndTests
//
//  Created by Henrique Batista on 14/02/24.
//

import XCTest
import EssentialDeveloper

final class EssentialDeveloperAPIEntToEndTests: XCTestCase {

	func test_entToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
		let testServerURl = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
		let client = URLSessionHTTPClient()
		let loader = RemoteFeedLoader(url: testServerURl, client: client)
		
		let exp = expectation(description: "Wait for remote completion")
		
		var receivedResult: LoadFeedResult?
		loader.load { result in
			receivedResult = result
			exp.fulfill()
		}
		wait(for: [exp], timeout: 5.0)
		
		switch receivedResult {
			case let .success(items):
				XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed")
			case let .failure(error):
				XCTFail("Expected successfull feed result, got \(error) instead")
			default:
				XCTFail("Expected successfull feed result, got no result instead")
		}
	}

}
