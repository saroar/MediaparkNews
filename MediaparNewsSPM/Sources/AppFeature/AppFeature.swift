//
//  AppState.swift
//  
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI
import ComposableArchitecture
import SwiftUIHelpers

import NewsFeature
import SearchFeature

public enum Tab: String, Equatable {
	case home, news, serach, profile, more
}

public struct AppState: Equatable {
	public var selectedTab = Tab.news
	public var newsState: NewsState
	public var searchState: SearchState
	public var tabBarIsHidden: Bool = false

	public init(
		newsState: NewsState = .init(),
		searchState: SearchState = .init(),
		tabBarIsHidden: Bool = false
	) {
		self.newsState = newsState
		self.searchState = searchState
		self.tabBarIsHidden = tabBarIsHidden
	}
}

extension AppState {
	var view: AppView.ViewState {
		get { .init(state: self)}
		set {
			self.selectedTab = newValue.selectedTab
		}
	}

}

extension AppState {
	static public var mock: AppState = .init(
		newsState: NewsState.mock,
		searchState: SearchState()
	)
}

public enum AppAction {
	case onAppear
	case tabBar(isHidden: Bool)
	case selectedTab(Tab)
	case news(NewsAction)
	case search(SearchAction)
}

extension AppAction {
	init(action: AppView.ViewAction) {
		switch action {
		case .onAppear:
			self = .onAppear
		case let .tabBar(isHidden: isHidden):
			self = .tabBar(isHidden: isHidden)
		case .selectedTab(let tab):
			self = .selectedTab(tab)
		case .news(let naction):
			self = .news(naction)
		case .search(let saction):
			self = .search(saction)
		}
	}
}


public struct AppEnvironment {
	public init() {}
}

extension AppEnvironment {
	static public let live: AppEnvironment = .init()
}


public var appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
	newsReducer.pullback(
		state: \.newsState,
		action: /AppAction.news,
		environment: { _ in
			NewsEnvironment.live
		}
	),

	searchReducer.pullback(
		state: \AppState.searchState,
		action: /AppAction.search,
		environment: { _ in
			SearchEnvironment.live
		}
	),

	Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in

	switch action {
	case .onAppear: return .none

	case .news(.setNavigation(tag: .articleDetails)):
		return Effect(value: AppAction.tabBar(isHidden: true))
			.receive(on: DispatchQueue.main.animation())
			.eraseToEffect()

	case .news(.setNavigation(tag: .none)):
		return Effect(value: AppAction.tabBar(isHidden: false))
			.receive(on: DispatchQueue.main.animation())
			.eraseToEffect()

	case .news: return .none


	case .search(.topBar(.searchBar(.isSortingViewIsActive))):

		state.searchState.topBarState.searchBarState?.isSortingButtonTapped.toggle()
		let isActive = state.searchState.topBarState.searchBarState?.isSortingButtonTapped ?? false

		print(#line, isActive)

		return Effect(value: AppAction.tabBar(isHidden: isActive))
			.receive(on: DispatchQueue.main.animation())
			.eraseToEffect()


	case let .search(.topBar(.searchBar(.filterNavigation(isActive: isActive)))):

		return Effect(value: AppAction.tabBar(isHidden: isActive))
			.receive(on: DispatchQueue.main.animation())
			.eraseToEffect()

	case .search: return .none

	case let .selectedTab(tab):
		state.selectedTab = tab
		return .none

	
	case .tabBar(isHidden: let isHidden):
		state.tabBarIsHidden = isHidden
		return .none
	}
})

public struct AppView: View {

	let store: Store<AppState, AppAction>

	public init(store: Store<AppState, AppAction>) {
		self.store = store
	}

	struct ViewState: Equatable {
		public init(state: AppState) {
			self.selectedTab = state.selectedTab
			self.tabBarIsHidden = state.tabBarIsHidden
		}

		public var tabBarIsHidden: Bool = false
		public var selectedTab: Tab
	}

	enum ViewAction {
		case onAppear
		case tabBar(isHidden: Bool)
		case selectedTab(Tab)
		case news(NewsAction)
		case search(SearchAction)
	}

	public var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			
			VStack {
				HidableTabView(
					isHidden:
						viewStore.binding(
							get: \.tabBarIsHidden,
							send: AppAction.tabBar
						),
					selection:
						viewStore.binding(
							get: \.selectedTab,
							send: AppAction.selectedTab
						)
				) {

					Text(Tab.home.rawValue.capitalized)
						.tabItem {
							Label(Tab.home.rawValue.capitalized, systemImage: "house")
						}
						.tag(Tab.home)

					NavigationView {
						NewsView(
							store: store.scope(
								state: \.newsState,
								action: AppAction.news
							)
						)
							.onAppear {
								viewStore.send(.news(.onAppear))
								viewStore.send(.tabBar(isHidden: false))


							}
//							.onDisappear {
//								viewStore.send(.tabBar(isHidden: true))
//							}
					}
					.tabItem {
						Label(Tab.news.rawValue.capitalized, systemImage: "circle.grid.2x2")
					}
					.tag(Tab.news)


					NavigationView {
						SearchView(
							store: store.scope(
								state: \.searchState,
								action: AppAction.search
							)
						)
						.onAppear {
							viewStore.send(.search(.onAppear))
							viewStore.send(.tabBar(isHidden: false))
						}
//						.onDisappear {
//							viewStore.send(.tabBar(isHidden: true))
//						}

					}
					.tabItem {
						Label(Tab.serach.rawValue.capitalized, systemImage: "magnifyingglass")
					}
					.tag(Tab.serach)


					Text("Profile")
						.tabItem {
							Label("Profile", systemImage: "person")
						}
						.tag(Tab.profile)

					Text("More")
						.tabItem {
							Label("More", systemImage: "ellipsis.circle.fill")
						}
						.tag(Tab.more)

				}
				.accentColor(Color.init(hex: "#f68f54"))
			}
		}
	}
}

struct AppView_Previews: PreviewProvider {
	static var previews: some View {

		let store = Store(
			initialState: AppState.mock,
			reducer: appReducer,
			environment: AppEnvironment()
		)

		AppView(store: store)

		AppView(store: store)
			.previewDevice(PreviewDevice(rawValue: "iPhone 8"))
			.previewDisplayName("iPhone 8")

	}
}
