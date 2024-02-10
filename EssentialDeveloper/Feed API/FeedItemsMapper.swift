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
		
		var feedItems: [FeedItemModel] {
			return items.map({ $0.item })
		}
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
	
	static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(.invalidData)
		}
		
		return .success(root.feedItems)
	}
}
