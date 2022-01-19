//
//  TopBarView.swift
//  MediaparkNews
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI
import SwiftUIHelpers
import ComposableArchitecture
import SearchBarFeature

public struct TopBarState: Equatable {
	public init(
		isSearchBarActive: Bool = false,
		searchBarState: SearchBarState? = nil
	) {
		self.isSearchBarActive = isSearchBarActive
		self.searchBarState = searchBarState
	}

	public var isSearchBarActive: Bool = false
	public var searchBarState: SearchBarState?

}

extension TopBarState {

	static public let live: TopBarState = .init()

	static public let mockWithsearchBarStateTrue: TopBarState = .init(
		isSearchBarActive: true,
		searchBarState: SearchBarState.mockWithsearchBarStateTrueWithSearchText
	)

	static public let mockWithsearchBarStateFalse: TopBarState = .init(
		isSearchBarActive: false,
		searchBarState: SearchBarState.mockWithsearchBarStateFalse
	)
}

public enum TopBarAction {
	case onAppear, onDisappear
	case searchBar(SearchBarAction)
	case isSearchBar(isActive: Bool)
}

public struct TopBarEnvironment {
	public init() {}
}

extension TopBarEnvironment {
	static public var live: TopBarEnvironment = .init()
}

public let topBarReducer = Reducer<TopBarState, TopBarAction, TopBarEnvironment>.combine(
	searchBarReducer
		.optional()
		.pullback(
			state: \TopBarState.searchBarState,
			action: /TopBarAction.searchBar,
			environment: { _ in
				SearchBarEnvironment()
			}
		), Reducer<TopBarState, TopBarAction, TopBarEnvironment> { state, action, environment in

			switch action {
			case .onAppear:
				state.searchBarState = state.isSearchBarActive ? SearchBarState() : nil
				return .none
			case .onDisappear:
				return .none
			case .searchBar(_):
				return .none
			case let .isSearchBar(isActive: isActive):
				return .none
			}
		}
)


public struct TopBarView: View {

	struct ViewState: Equatable {
		var isSearchBarActive: Bool
		var searchBarState: SearchBarState?

		init(state: TopBarState) {
			self.isSearchBarActive = state.isSearchBarActive
			self.searchBarState = state.searchBarState
		}
	}

	public let store: Store<TopBarState, TopBarAction>

	public init(store: Store<TopBarState, TopBarAction>) {
		self.store = store
	}

	public var body: some View {
		WithViewStore(store.scope(state: ViewState.init)) { viewStore in
			VStack {
				HStack {
					Text("Logo")
						.font(.largeTitle).italic().bold()
						.foregroundColor(Color(hex: "#F68F54"))
						.padding()
				}

				IfLetStore(
					store.scope(
						state: \.searchBarState,
						action: TopBarAction.searchBar
					)
				) { searBarStore in
					SearchBarView(store: searBarStore)
						.onAppear {
							viewStore.send(.searchBar(.onAppear))
						}
						.padding(.bottom, 20)
				}

			}
			.onDisappear {
				if viewStore.searchBarState != nil {
					viewStore.send(.searchBar(.setIsEditing(false)))
				}
			}
			.frame(maxWidth: .infinity)
			.background(Color(UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)))
			.cornerRadius(20, corners: [.bottomLeft, .bottomRight])
			.transition(.slide)
		}
	}
}

//struct TopBarView_Previews: PreviewProvider {
//	static var previews: some View {
//
//		let store = Store(
//			initialState: TopBarState.mockWithsearchBarStateTrue,
//			reducer: topBarReducer,
//			environment: TopBarEnvironment()
//		)
//
//		VStack {
//			TopBarView(store: store)
//			Spacer()
//		}
//		.background(Color.gray)
//
//		VStack {
//			TopBarView(store: store)
//			Spacer()
//		}
//		.previewDevice(PreviewDevice(rawValue: "iPhone 8"))
//		.previewDisplayName("iPhone 8")
//		.background(Color.gray)
//	}
//}
