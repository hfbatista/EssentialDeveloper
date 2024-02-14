//
//  URLSessionHTTPClient.swift
//  EssentialDeveloper
//
//  Created by Henrique Batista on 13/02/24.
//

import Foundation

public class URLSessionHTTPClient: HTTPCLientProtocol {
	private let session: URLSession
	
	public init(session: URLSession = .shared) {
		self.session = session
	}
	
	private struct UnexpectedErroWithNoValiues: Error {}
	
	public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { data, response, error in
			if let error {
				completion(.failure(error))
			} else if let data = data, let response = response as? HTTPURLResponse {
				completion(.success(data, response))
			} else {
				completion(.failure(UnexpectedErroWithNoValiues()))
			}
		}.resume()
	}
}
