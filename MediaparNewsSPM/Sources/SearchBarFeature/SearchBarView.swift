//
//  SwiftUIView.swift
//  MediaparkNews
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI
import ComposableArchitecture
import SearchBarFilter
import TcaHelpers
import Models

public class UserDefaultsClient {
	public static var sortingPublisher: Effect<Sorting, Never> {
		UserDefaults.$sorting.eraseToEffect()
	}
}

struct SearchBarClient {}

public struct SearchBarState: Equatable {
	public init(
		searchText: String = "",
		isEditing: Bool = false,
		budgeCounter: Int = 0
	) {
		self.searchText = searchText
		self.isEditing = isEditing
	}

	public var searchText: String = ""
	public var isEditing = false
	public var isSortingButtonTapped = false
	public var budgeCounter: Int = 0

}


extension SearchBarState {
	static public let mockWithsearchBarStateTrue: SearchBarState = .init(
		isEditing: true
	)

	static public let mockWithsearchBarStateFalse: SearchBarState = .init()

	static public let mockWithsearchBarStateTrueWithSearchText: SearchBarState = .init(
		searchText: "super",
		isEditing: true
	)
}

public enum SearchBarAction {
	case onAppear
	case setIsEditing(Bool)
	case isSortingViewIsActive
	case searchQueryChanged(String)

	case searchBarFilter(SearchBarFilterAction)
	case filterNavigation(isActive: Bool)
	case sortingResponse(Result<Sorting, Never>)
}

//extension SearchBarAction {
//	init(action: SearchBarView.ViewAction) {
//		switch action {
//		case .onAppear:
//			self = .onAppear
//		case .setIsEditing(let bool):
//			self = .setIsEditing(bool)
//		case .searchQueryChanged(let string):
//			self = .searchQueryChanged(string)
//		case .searchBarFilter(let sbfAction):
//			self = .searchBarFilter(sbfAction)
//		case .setNavigation(tag: let tag):
//			self = .setNavigation(tag: tag)
//		}
//	}
//}

public struct SearchBarEnvironment {
	public init() {}
}

public let searchBarReducer = Reducer<SearchBarState, SearchBarAction, SearchBarEnvironment>  { state, action, environment in
	switch action {

	case .onAppear:
		return UserDefaultsClient
			.sortingPublisher
			.receive(on: DispatchQueue.main)
			.catchToEffect(SearchBarAction.sortingResponse)

	case let .setIsEditing(bool):
		return .none

	case .isSortingViewIsActive:
		return .none

	case let .searchQueryChanged(query):
		state.searchText = ""
		return .none

	case .searchBarFilter(_):
		return .none

	case .filterNavigation(isActive: let isActive):
		return .none

	case let .sortingResponse(.success(sortingResponse)):
		return .none
	}
}

public struct SearchBarView: View {

	struct ViewState: Equatable {

		init(state: SearchBarState) {
			self.searchText = state.searchText
			self.isEditing = state.isEditing
			self.isSortingButtonTapped = state.isSortingButtonTapped
			self.budgeCounter = state.budgeCounter
		}

		let searchText: String
		let isEditing: Bool
		let isSortingButtonTapped: Bool
		let budgeCounter: Int

	}

	let store: Store<SearchBarState, SearchBarAction>

	public init(store: Store<SearchBarState, SearchBarAction>) {
		self.store = store
	}

	public var body: some View {

		WithViewStore(store.scope(state: ViewState.init)) { viewStore in
			ZStack {
				HStack {
					TextField(
						"Search",
						text: viewStore.binding(get: \.searchText, send: SearchBarAction.searchQueryChanged)
					)
					.frame(height: 46)
					.padding(.vertical, 5)
					.padding(.horizontal, 40)
					.background(Color(.systemGray6))
					.cornerRadius(100)
					.overlay(
						HStack {
							Image(systemName: "magnifyingglass")
								.foregroundColor(.gray)
								.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
								.padding(.leading, 14)

							if viewStore.isEditing {
								Button(action: { withAnimation {
									viewStore.send(.searchQueryChanged(""))
									viewStore.send(.setIsEditing(false))
								}
								}) {
									Image(systemName: "multiply.circle.fill")
										.foregroundColor(.gray)
										.padding(.trailing, 10)
								}
							}
						}
					)
					.padding(.horizontal, 10)
					.onTapGesture {
						withAnimation {
							viewStore.send(.setIsEditing(true))
						}
					}

					if !viewStore.isEditing {

						HStack {
							Button(action: {
								viewStore.send(.filterNavigation(isActive: true), animation: .default)
							}) {
								Image(systemName: "paintbrush")
									.frame(width: 46, height: 46)
							}

							.padding(5)
							.transition(.move(edge: .trailing))
							.background(Color(.systemGray6))
							.clipShape(Circle())
							.overlay(
								Text("\(viewStore.budgeCounter)")
									.font(.custom("OpenSans-Regular", size: 13, relativeTo: .headline))
									.frame(width: 20, height: 20)
									.foregroundColor(.white)
									.background(Color.red)
									.clipShape(Circle()),
								alignment: .topTrailing
							)

							Button(action: {
								viewStore.send(.isSortingViewIsActive)
							}) {
								Image(systemName: "arrow.down")
									.frame(width: 40, height: 40, alignment: .center)
							}
							.frame(width: 46, height: 46)
							.padding(5)
							.transition(.move(edge: .trailing))
							.background(Color(.systemGray6))
							.clipShape(Circle())
						}
						.accentColor(.black)
						.padding(.trailing, 15)
					}
				}
			}
		}

	}
}

struct SearchBarView_Previews: PreviewProvider {
	
	static var previews: some View {
		let store = Store(
			initialState: SearchBarState.mockWithsearchBarStateTrueWithSearchText,
			reducer: searchBarReducer,
			environment: SearchBarEnvironment()
		)
		SearchBarView(store: store)
	}
}
