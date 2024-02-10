//
//  RemoteFeedLoader.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 09/02/24.
//

import Foundation

public enum HTTPClientResult {
	case success(HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPCLientProtocol {
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
	let client: HTTPCLientProtocol
	let url: URL
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPCLientProtocol) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Error) -> Void) {
		client.get(from: url) { result in
			switch result {
				case .success:
					completion(.invalidData)
				case .failure:
					completion(.connectivity)
			}
		}
	}
}


