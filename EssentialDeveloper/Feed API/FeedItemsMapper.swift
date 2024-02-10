//
//  FeedItemsMapper.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 10/02/24.
//

import Foundation

class FeedItemsMapper {
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
