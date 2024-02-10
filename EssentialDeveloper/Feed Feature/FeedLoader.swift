//
//  FeedLoader.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 08/02/24.
//

import Foundation

public enum LoadFeedResult {
	case success([FeedItemModel])
	case failure(Error)
}

protocol FeedLoaderProtocol {
	func load (completion: @escaping (LoadFeedResult) -> Void)
}
