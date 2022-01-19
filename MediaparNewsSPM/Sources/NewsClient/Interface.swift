//
//  File.swift
//  
//
//  Created by 19172093 on 09.01.2022.
//

import SwiftUI
import ComposableArchitecture
import Combine
import Foundation
import Models

public struct NewsClient {

	public var news: () -> Effect<News, NewsError>
	public var search: (String, Sorting) -> Effect<News, NewsError>

	public init(
		news: @escaping () -> Effect<News, NewsError>,
		search: @escaping (String, Sorting) -> Effect<News, NewsError>
	) {
		self.news = news
		self.search = search
	}
}

extension NewsClient {
	public static var live: NewsClient = .init {

		guard let request = NetworkClient.shared.makeRequest(
			endPoint: .tophHeadlines,
			httpMethod: .GET
		) else {
			return Effect(value: News())
		}

		return URLSession.shared.dataTaskPublisher(for: request)
			.assumeHTTP()
			.responseData()
			.decoding(News.self, decoder: JSONDecoder())
			.catch { (error: NewsError) -> AnyPublisher<News, NewsError> in
				return Fail(error: error).eraseToAnyPublisher()
			}
			.receive(on: DispatchQueue.main)
			.eraseToEffect()
		
	} search: { string, sorting in
//		guard let request = NetworkClient.shared.makeSearchRequest(
//			endPoint: .search,
//			httpMethod: .GET,
//			matching: string,
//			sortedBy: sorting
//		) else {
//			return Effect(value: News())
//		}

		guard let request = NetworkClient.shared.makeSearchRequest(
			endPoint: .search,
			httpMethod: .GET,
			matching: string,
			sortedBy: sorting
		)
		else {
			return Effect(value: News())
		}

		return URLSession.shared.dataTaskPublisher(for: request)
			.assumeHTTP()
			.responseData()
			.decoding(News.self, decoder: JSONDecoder())
			.catch { (error: NewsError) -> AnyPublisher<News, NewsError> in
				return Fail(error: error).eraseToAnyPublisher()
			}
			.receive(on: DispatchQueue.main)
			.eraseToEffect()
	}

}

extension NewsClient {
	public static var mocks: NewsClient = .init {
		return Just(News.mock)
			.setFailureType(to: NewsError.self)
			.eraseToEffect()
	} search: { string, sorting in
		Just(News.mock)
			.setFailureType(to: NewsError.self)
			.eraseToEffect()
	}

	public static var mockWithNews: NewsClient = .init {
		Just(News.mockWith3Articles)
			.setFailureType(to: NewsError.self)
			.eraseToEffect()

	} search: { string, sorting in
		Just(News.mock)
			.setFailureType(to: NewsError.self)
			.eraseToEffect()
	}
}


public typealias APIKey = String
// curl "https://gnews.io/api/v4/top-headlines?token=1930f6305e3585095b65845b7cc3e594"
//       https://gnews.io/api/v4/tophHeadlines?token=1930f6305e3585095b65845b7cc3e594

// GET curl "https://gnews.io/api/v4/search?q=apple&token=1930f6305e3585095b65845b7cc3e594"

public enum Constants {
	public static let scheme = "https"
	public static let host = "gnews.io"
	public static let version = "/api/v4"
}

enum Method: String {
	case GET
}

public final class NetworkClient {
	public static let shared = NetworkClient()

	public init() {}

	private func makeComponents() -> URLComponents {
		var components = URLComponents()
		components.scheme = Constants.scheme
		components.host = Constants.host
		components.path = Constants.version

		components.queryItems = [
			URLQueryItem(name: "token", value: "1930f6305e3585095b65845b7cc3e594")
		]

		return components
	}

	func makeRequest(
		endPoint: Endpoint,
		httpMethod: Method) -> URLRequest? {

		let components = makeComponents()

		guard var url = components.url else {
			return nil
		}

		url.appendPathComponent(endPoint.rawValue)

		var request = URLRequest(url: url)
		request.httpMethod = httpMethod.rawValue

		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		return request

	}


	// GET curl "https://gnews.io/api/v4/search?q=apple&token=1930f6305e3585095b65845b7cc3e594"
	func makeSearchRequest(
		endPoint: Endpoint,
		httpMethod: Method,
		matching query: String,
		sortedBy sorting: Sorting
	) -> URLRequest? {

		var components = URLComponents()
		components.scheme = Constants.scheme
		components.host = Constants.host
		components.path = Constants.version

		components.queryItems = [
			URLQueryItem(name: "token", value: "1930f6305e3585095b65845b7cc3e594")
		]

		let searchInStrings = sorting.searchIn.filter { $0.isOn == true }
			.map { $0.name }
			.joined(separator: ",")

		let q = URLQueryItem(name: Sorting.Parameters.q.rawValue, value: query)
		components.queryItems?.append(q)

		if sorting.from != nil {
			components.queryItems?.append(URLQueryItem(name: Sorting.Parameters.from.rawValue, value: sorting.from))
		}

		if sorting.to != nil {
			components.queryItems?.append(URLQueryItem(name: Sorting.Parameters.from.rawValue, value: sorting.to))
		}

		let searchIn = URLQueryItem(name: Sorting.Parameters.in.rawValue, value: searchInStrings)
		components.queryItems?.append(searchIn)

		guard var url = components.url else { return nil }

		url.appendPathComponent(endPoint.rawValue)

		var request = URLRequest(url: url)
		request.httpMethod = httpMethod.rawValue

		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		return request

	}
}

enum Endpoint: String {
	case tophHeadlines = "top-headlines"
	case search
}

public enum CodingKeys: String, CodingKey {
	case title
	case articleDescription = "description"
	case content, url, image, publishedAt, source
}
