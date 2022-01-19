//
//  SearchView.swift
//  MediaparkNews
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI
import ComposableArchitecture
import SwiftUIHelpers
import TopBarFeature
import NewsClient
import Models
import UserDefaultsClient
import ArticleFeature
import SearchBarFeature

import SearchBarFilter
import SearchBarFilterSectors

public let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment>.combine(
	topBarReducer.pullback(
		state: \SearchState.topBarState,
		action: /SearchAction.topBar,
		environment: { _ in
			TopBarEnvironment()
		}
	),

	searchBarFilterReducer
	   ._pullback(
			state: (\SearchState.route)
				.appending(path: /SearchRoute.filter),
			action: /SearchAction.searchBarFilter,
			environment: { _ in () }
	   ),

	sortingByReducer.optional()
		.pullback(
			state: \.sortingByState,
			action: /SearchAction.sortingBy,
			environment: { _ in () }
		),

	.init { state, action, environment in

		switch action {
		case .onAppear:
			state.topBarState = TopBarState(isSearchBarActive: true)

			return UserDefaultsClient
				.searchHistoriesPublisher
				.catchToEffect(SearchAction.searchHistoriesResponse)

		case let .topBar(.searchBar(.searchQueryChanged(query))):
			state.topBarState.searchBarState?.searchText = query
			
			struct SearchTextId: Hashable {}

			var sorting = Sorting()

			guard !query.isEmpty else {
				return .cancel(id: SearchTextId())
			}

			let set = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcefghijklmnopqrstuvwxyz ")
			let cleanInput = query.components(separatedBy: set.inverted).joined()
			state.currentSearchString = cleanInput

			return environment.newsClient.search(cleanInput, sorting)
				.debounce(id: SearchTextId(), for: .seconds(1), scheduler: environment.mainQueue)
				.catchToEffect()
				.map(SearchAction.newsResponse)

		case let .topBar(.searchBar(.setIsEditing(bool))):
			state.topBarState.searchBarState?.isEditing = bool
			return .none

		case .topBar(.searchBar(.isSortingViewIsActive)):

			state.isSortingButtonTapped.toggle()
			state.sortingByState = state.isSortingButtonTapped ? SortingByState() : nil

			return .none

		case let .topBar(.searchBar(.filterNavigation(isActive: isActive))):
			state.route = isActive ? .filter(.init()) : nil
			return .none

		case let .topBar(.searchBar(.sortingResponse(.success(sortingResponse)))):
			state.topBarState.searchBarState?.budgeCounter = sortingResponse.searchIn.filter { $0.isOn == true }.count
			state.topBarState.searchBarState?.budgeCounter += sortingResponse.from == nil ? 0 : 1
			state.topBarState.searchBarState?.budgeCounter += sortingResponse.to == nil ? 0 : 1

		 return .none

		case .topBar: return .none

		case let .newsResponse(.success(newsResponse)):
			state.news = newsResponse
			state.articles = .init(uniqueElements: state.news.articles)

			if !state.currentSearchString.isEmpty {
				let queryS = QueryHistory(query: state.currentSearchString)
				if !state.searchHistories.contains(queryS) {
					state.searchHistories.append(queryS)
				}
				UserDefaults.searchHistories = state.searchHistories
			}

			state.currentQueryReponseCount = state.news.articles.count

			return .none

		case let .newsResponse(.failure(error)):
			return .none

		case let .searchHistoriesResponse(.success(searchHistoriesResponse)):
			state.searchHistories = searchHistoriesResponse

			return .none

		case let .searchHistoriesResponse(.failure(error)):
			return .none

		case let .setNavigation(tag: tag):
			switch tag {
			case .filter:
				state.route = .filter(.init())
				return .none
			case .sectors:
				state.route = .sectors(.init())
			case .none:
				state.route = .none
				return .none
			}
			return .none
		case .searchBarFilter(_):
			return .none

		case .sortingBy(.closeView):
			return Effect(value: SearchAction.topBar(.searchBar(.isSortingViewIsActive)))
				.receive(on: DispatchQueue.main.animation())
				.eraseToEffect()

		case .sortingBy(_):
			return .none

		}
	}
).debug()

public struct SearchView: View {

	public struct ViewState: Equatable {

		let topBarState: TopBarState
		let news: News
		let articles: IdentifiedArrayOf<Article>
		let searchHistories: [QueryHistory]
		let currentSearchString: String
		let currentQueryReponseCount: Int
		let isSortingButtonTapped: Bool
		let tag: SearchRoute.Tag?
		let showingSortingByViewSheet: Bool

		public init(state: SearchState) {
			self.topBarState = state.topBarState
			self.news = state.news
			self.articles = state.articles
			self.searchHistories = state.searchHistories
			self.currentSearchString = state.currentSearchString
			self.currentQueryReponseCount = state.currentQueryReponseCount
			self.isSortingButtonTapped = state.isSortingButtonTapped
			self.tag = state.route?.tag
			self.showingSortingByViewSheet = state.showingSortingByViewSheet
		}
	}

	public let store: Store<SearchState, SearchAction>

	public init(store: Store<SearchState, SearchAction>) {
		self.store = store
	}

	public var body: some View {

		WithViewStore(store.scope(state: ViewState.init) ) { viewStore in
			ZStack(alignment: .bottom) {
			VStack {
				TopBarView(
					store: store.scope(
						state: \.topBarState,
						action: SearchAction.topBar
					)
				).onAppear {
					viewStore.send(.topBar(.onAppear))
				}

				VStack {
					if let searchBarState = viewStore.topBarState.searchBarState, searchBarState.isEditing {
						VStack {
							searchTitle(viewStore.currentQueryReponseCount, title: "News")
								.opacity(viewStore.currentQueryReponseCount > 0 ? 1 : 0)

							ScrollView {
								ForEachStore(
									store.scope(
										state: \.articles,
										action: SearchAction.article(id:action:)
									)
								) { newsStore in
									WithViewStore(newsStore) { articleViewStore in
										ArticleRowView(store: newsStore)
									}
								}

							}
							.padding(.top, -5)
						}
						.listRowBackground(Color(UIColor(hexString: "#E5E5E5")))

					} else {
						VStack {
							searchTitle(title: "Search History")

							ScrollView {
								ForEach(viewStore.searchHistories.sorted(by: <), id: \.self) { queryS in
									Text(queryS.query)
										.frame(maxWidth: .infinity, alignment: .leading)
										.padding()
									Divider()
								}
							}
							.padding(.top, -5)
						}
						.listRowBackground(Color(UIColor(hexString: "#E5E5E5")))
					}
				}
				.padding()

			}
			.navigationBarHidden(true)
			.background(Color(UIColor(hexString: "#E5E5E5")))
				IfLetStore(
					self.store.scope(
						state: \.sortingByState,
						action: SearchAction.sortingBy
					),
					then: SortingByView.init(store:)
				)
			}
			.background(
				NavigationLink(
					destination: IfLetStore(
						self.store.scope(
							state: (\SearchState.route)
								.appending(path: /SearchRoute.filter)
								.extract(from:),
							action: SearchAction.searchBarFilter
						),
						then: SearchBarFilterView.init(store:)
					),
					tag: SearchRoute.Tag.filter,
					selection: viewStore.binding(
						get: \.tag,
						send: SearchAction.setNavigation(tag:)
					)
					.animation()
				) {}
			)
		}
	}

	private func searchTitle(_ count: Int = 0, title: String) -> some View {
		return Text(count == 0 ? title : "\(count) \(title)" )
			.font(.custom("OpenSans-Bold", size: 30, relativeTo: .headline))
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.top, 20)
			.padding(.leading)
	}
}

struct SearchView_Previews: PreviewProvider {

	static var previews: some View {

		let storeQueryHistories = Store(
			initialState: SearchState.searchHistories,
			reducer: searchReducer,
			environment: SearchEnvironment.mock
		)
		
		let storeQueryResponse = Store(
			initialState: SearchState.queryHistories,
			reducer: searchReducer,
			environment: SearchEnvironment.mockWithNews
		)

		VStack {
			SearchView(store: storeQueryHistories)
		}

		VStack {
			SearchView(store: storeQueryResponse)
		}
		.previewDevice(PreviewDevice(rawValue: "iPhone 8"))
		.previewDisplayName("iPhone 8")

	}
}
