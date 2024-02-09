//
//  RemoteFeedLoader.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 09/02/24.
//

import Foundation

public protocol HTTPCLientProtocol {
	func get(from url: URL)
}

public final class RemoteFeedLoader {
	let client: HTTPCLientProtocol
	let url: URL
	
	public init(url: URL, client: HTTPCLientProtocol) {
		self.url = url
		self.client = client
	}
	
	public func load() {
		client.get(from: url)
	}
}


