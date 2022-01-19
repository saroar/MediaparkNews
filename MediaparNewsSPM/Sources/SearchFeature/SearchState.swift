//
//  SearchState.swift
//  
//
//  Created by 19172093 on 16.01.2022.
//

import SwiftUI
import ComposableArchitecture
import SwiftUIHelpers
import Models
import UserDefaultsClient

import TopBarFeature
import SearchBarFeature
import SearchBarFilter
import SearchBarFilterSectors

public enum SearchRoute: Equatable {
	case filter(SearchBarFilterState)
	case sectors(SearchBarFilterSectorsState)

	public enum Tag: Int {
		case filter
		case sectors
	}

	var tag: Tag {
		switch self {
		case .filter:
			return .filter
		case .sectors:
			return.sectors
		}
	}
}


public struct SearchState: Equatable {

	public var topBarState: TopBarState
	public var news: News = .init()
	public var articles: IdentifiedArrayOf<Article> = []
	public var searchHistories: [QueryHistory] = []
	public var currentSearchString: String = ""
//	public var isEditing: Bool = false
	public var currentQueryReponseCount = 0
	public var isSortingButtonTapped = false
	public var route: SearchRoute?
	public var sortingByState: SortingByState?
	public var showingSortingByViewSheet: Bool = false

	public init(
		topBarState: TopBarState = .init(),
		news: News = .init(),
		articles: IdentifiedArrayOf<Article> = [],
		searchHistories: [QueryHistory] = [],
		currentSearchString: String = "", isEditing: Bool = false,
		currentQueryReponseCount: Int = 0,
		route: SearchRoute? = nil,
		sortingByState: SortingByState? = nil
	) {
		self.topBarState = topBarState
		self.news = news
		self.articles = articles
		self.searchHistories = searchHistories
		self.currentSearchString = currentSearchString
//		self.isEditing = isEditing
		self.currentQueryReponseCount = currentQueryReponseCount
		self.route = route
		self.sortingByState = sortingByState
	}
}

extension SearchState {
	static let searchHistories: SearchState = .init(
		topBarState: TopBarState.mockWithsearchBarStateTrue,
		news: News.mock, searchHistories: [
			QueryHistory.qh, QueryHistory.qh1, QueryHistory.qh2
		],
		currentSearchString: "", isEditing: false
	)

	static let queryHistories: SearchState = .init(
		topBarState: TopBarState.mockWithsearchBarStateTrue,
		news: News.mockWith3Articles,
		searchHistories: [], currentSearchString: "",
		isEditing: true, currentQueryReponseCount: 3
	)
}

