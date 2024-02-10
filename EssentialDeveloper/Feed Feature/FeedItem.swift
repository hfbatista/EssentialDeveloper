//
//  FeedItem.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 08/02/24.
//

import Foundation

public struct FeedItemModel: Equatable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let imageURL: URL
	
	public init(id: UUID, description: String?, location: String?, imageURL: URL) {
		self.id = id
		self.description = description
		self.location = location
		self.imageURL = imageURL
	}
	
}
