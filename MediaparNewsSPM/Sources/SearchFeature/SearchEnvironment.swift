//
//  SearchEnvironment.swift
//  
//
//  Created by 19172093 on 16.01.2022.
//

import SwiftUI
import ComposableArchitecture
import SwiftUIHelpers
import Models
import UserDefaultsClient
import NewsClient


public struct SearchEnvironment {
	public init(
		mainQueue: AnySchedulerOf<DispatchQueue>,
		newsClient: NewsClient
	) {
		self.mainQueue = mainQueue
		self.newsClient = newsClient
	}

	public var mainQueue: AnySchedulerOf<DispatchQueue>
	public var newsClient: NewsClient

}

extension SearchEnvironment {
	static public let live: SearchEnvironment = .init(
		mainQueue: .main,
		newsClient: .live
	)
}

extension SearchEnvironment {
	static public let mock: SearchEnvironment = .init(
		mainQueue: .immediate,
		newsClient: .mocks
	)

	static public let mockWithNews: SearchEnvironment = .init(
		mainQueue: .immediate,
		newsClient: .mockWithNews
	)

}

