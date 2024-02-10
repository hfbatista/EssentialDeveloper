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

private class FeedItemsMapper {
	private struct Root: Decodable {
		let items: [ApiFeedItem]
	}
	
	private struct ApiFeedItem: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let image: URL
		
		var item: FeedItemModel {
			return FeedItemModel(id: id, description: description, location: location, imageURL: image)
		}
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItemModel] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		
		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map({ $0.item })
	}
}


