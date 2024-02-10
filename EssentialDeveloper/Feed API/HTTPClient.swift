//
//  HTTPClient.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 10/02/24.
//

import Foundation

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPCLientProtocol {
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
