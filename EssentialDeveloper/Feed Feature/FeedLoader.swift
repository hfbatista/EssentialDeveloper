//
//  FeedLoader.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 08/02/24.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
	case success([FeedItemModel])
	case failure(Error)
}

protocol FeedLoaderProtocol {
	associatedtype Error: Swift.Error
	func load (completion: @escaping (LoadFeedResult<Error>) -> Void)
}
