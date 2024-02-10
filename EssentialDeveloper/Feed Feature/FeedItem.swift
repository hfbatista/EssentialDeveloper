//
//  FeedItem.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 08/02/24.
//

import Foundation

public struct FeedItemModel: Equatable {
	let id: UUID
	let description: String?
	let location: String?
	let imageURL: URL
}
