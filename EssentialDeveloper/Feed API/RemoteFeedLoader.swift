//
//  RemoteFeedLoader.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 09/02/24.
//

import Foundation

public protocol HTTPCLientProtocol {
	func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
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
		client.get(from: url) { error, response in
			
			if response != nil {
				completion(.invalidData)
			} else {
				completion(.connectivity)
			}
			
		}
	}
}


