//
//  RemoteFeedLoader.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 09/02/24.
//

import Foundation

public final class RemoteFeedLoader {
	let client: HTTPCLientProtocol
	let url: URL
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public enum Result: Equatable {
		case success([FeedItemModel])
		case failure(Error)
	}
	
	public init(url: URL, client: HTTPCLientProtocol) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
				case let .success(data, response):
					do {
						let items = try FeedItemsMapper.map(data, response)
						completion(.success(items))
					} catch {
						completion(.failure(.invalidData))
					}
				case .failure:
					completion(.failure(.connectivity))
			}
		}
	}
}
