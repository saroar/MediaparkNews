//
//  SearchAction.swift
//  
//
//  Created by 19172093 on 16.01.2022.
//

import SwiftUI
import ComposableArchitecture
import SwiftUIHelpers
import Models
import UserDefaultsClient
import ArticleFeature

import TopBarFeature
import SearchBarFeature
import SearchBarFilter
import SearchBarFilterSectors

public enum SearchAction {
	case onAppear
	case topBar(TopBarAction)
	case newsResponse(Result<News, NewsError>)
	case searchHistoriesResponse(Result<[QueryHistory], Never>)
	case article(id: Article.ID, action: ArticleAction)

	case setNavigation(tag: SearchRoute.Tag?)
	case searchBarFilter(SearchBarFilterAction)
	case sortingBy(SortingByAction)
}

extension UserDefaults {
	// MARK: - Words
	@UserDefaultPublished(UserDefaultKeys.searchHistories.rawValue, defaultValue: [])
	public static var searchHistories: [QueryHistory]

	@UserDefaultPublished(UserDefaultKeys.sorting.rawValue, defaultValue: Sorting())
	public static var sorting: Sorting

}

public class UserDefaultsClient {
	public static var sortingPublisher: Effect<Sorting, Never> {
		UserDefaults.$sorting.eraseToEffect()
	}

	public static var searchHistoriesPublisher: Effect<[QueryHistory], Never> {
		UserDefaults.$searchHistories.eraseToEffect()
	}
}
