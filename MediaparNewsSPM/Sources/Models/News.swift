//
//  File.swift
//  
//
//  Created by 19172093 on 10.01.2022.
//

import Foundation

// MARK: - Welcome
public struct News: Codable, Equatable, Hashable {

	public var totalArticles: Int = 0
	public var articles: [Article] = []

	public init(
		totalArticles: Int = 0,
		articles: [Article] = []
	) {
		self.totalArticles = totalArticles
		self.articles = articles
	}
}

extension News {
	static public let mock: News = .init(totalArticles: 0, articles: [])
	static public let mockWith3Articles: News = .init(totalArticles: 3, articles: [Article.mock, Article.mock1, Article.mock2])
}



extension News {
	static public var news: News = .init(
		totalArticles: 4,
		articles: [Article.mock]
	)
}
