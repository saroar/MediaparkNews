//
//  SearchBarFiltterSectors.swift
//  MediaparkNews
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI
import SwiftUIHelpers
import UserDefaultsClient
import Models
import ComposableArchitecture

extension UserDefaults {
	@UserDefaultPublished(UserDefaultKeys.sorting.rawValue, defaultValue: Sorting())
	public static var sorting: Sorting
}

public class UserDefaultsClient {
	public static var sortingPublisher: Effect<Sorting, Never> {
		UserDefaults.$sorting.eraseToEffect()
	}
}

public struct SearchBarFilterSectorsState: Equatable {
	public init(
		searchIn: IdentifiedArrayOf<Sorting.SearchIn> = .init(uniqueElements: Sorting().searchIn)
	) {
		self.sbFilterSectors = searchIn
	}

	public var sbFilterSectors: IdentifiedArrayOf<Sorting.SearchIn> = []
}

extension SearchBarFilterSectorsState {
	var view: SearchBarFiltterSectorsView.ViewState {
		SearchBarFiltterSectorsView.ViewState(state: self)
	}
}

public enum SearchBarFilterSectorsAction {
	case onAppear
	case applyButtonTapped
	case clearTabBarButtonTapped
	case toggle(id: Sorting.SearchIn.ID, action: SearchBarFilterSectorToggleAction)
	case searchFilterResponse(Result<Sorting, Never>)
}

extension SearchBarFilterSectorsAction {
	init(action: SearchBarFiltterSectorsView.ViewAction)  {
		switch action {

		case .onAppear:
			self = .onAppear
		case .applyButtonTapped:
			self = .applyButtonTapped
		case .clearTabBarButtonTapped:
			self = .clearTabBarButtonTapped
		case let .toggle(id: id, action: action):
			self = .toggle(id: id, action: action)
		case let .searchFilterResponse(response):
			self = .searchFilterResponse(response)
		}
	}
}

public let sbFilterSectorsReducer = Reducer<
	SearchBarFilterSectorsState, SearchBarFilterSectorsAction, Void
>.combine(
	searchFilterSectorToggleReducer.forEach(
		state: \.sbFilterSectors,
		action: /SearchBarFilterSectorsAction.toggle(id:action:),
		environment: { _ in }

	), Reducer<SearchBarFilterSectorsState, SearchBarFilterSectorsAction, Void> { state, action, _ in
	switch action {
	case .onAppear:

		return UserDefaultsClient
			.sortingPublisher
			.catchToEffect(SearchBarFilterSectorsAction.searchFilterResponse)

	case .applyButtonTapped:

		var sorting = UserDefaults.sorting
		sorting.searchIn = state.sbFilterSectors.map { $0 }
		UserDefaults.sorting = sorting

		return .none

	case .clearTabBarButtonTapped:
		var sorting = UserDefaults.sorting
		sorting.searchIn = Sorting.SearchIn.searchInKeys
		UserDefaults.sorting = sorting

		return .none

	case let .toggle(id: id, action: action):

		print(#line, id, action)
		return .none

	case let .searchFilterResponse(.success(result)):
		state.sbFilterSectors = .init(uniqueElements: result.searchIn)
		return .none

	}
})

public struct SearchBarFiltterSectorsView: View {

	@Environment(\.presentationMode) var presentationMode

	struct ViewState: Equatable {
		var sbFilterSectors: IdentifiedArrayOf<Sorting.SearchIn>

		init(state: SearchBarFilterSectorsState) {
			self.sbFilterSectors = state.sbFilterSectors
		}
	}

	enum  ViewAction {
		case onAppear
		case applyButtonTapped
		case clearTabBarButtonTapped
		case toggle(id: Sorting.SearchIn.ID, action: SearchBarFilterSectorToggleAction)
		case searchFilterResponse(Result<Sorting, Never>)
	}

	public var store: Store<SearchBarFilterSectorsState, SearchBarFilterSectorsAction>

	public init(store: Store<SearchBarFilterSectorsState, SearchBarFilterSectorsAction>) {
		self.store = store
	}

	public var body: some View {

		WithViewStore(store.stateless) { viewStore in
			ZStack {
				VStack {

					HStack {

						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Image(systemName: "arrow.left")
						}).padding(.leading)

						Spacer()

						Text("Logo") // change Logo Font
							.font(.custom("OpenSans-BoldItalic", size: 30, relativeTo: .headline))
							.foregroundColor(Color(hex: "#F68F54"))

						Spacer()

						Button(action: {
							viewStore.send(.clearTabBarButtonTapped)
						}, label: {
							Text("Clear")
								.font(.custom("OpenSans-Semibold", size: 14, relativeTo: .headline))
							Image(systemName: "trash")
						})
							.padding(.trailing)


					}
					.accentColor((Color(hex: "#F68F54")))

					VStack {
						Text("Search in")
							.font(.custom("OpenSans-Bold", size: 16, relativeTo: .headline))
							.frame(maxWidth: .infinity, alignment: .leading)

						ForEachStore(
							self.store.scope(
								state: \.sbFilterSectors,
								action: SearchBarFilterSectorsAction.toggle(id:action:)
							),
							content: SearchBarFilterSectorToggleView.init(store:)
						)
//						{ childStore in
//							WithViewStore(childStore) { childView in
//							VStack {
//								Toggle(
//									isOn: childView.binding(
//										get: \.isOn,
//										send: SearchBarFilterSectorToggleAction.togglePressed(isOn:)
//									)
//								) {
//									Text(childView.name.capitalized)
//										.font(.custom("OpenSans-SemiBold", size: 14, relativeTo: .headline))
//										.frame(maxWidth: .infinity, alignment: .leading)
//										.foregroundColor(Color.black)
//								}
//								.toggleStyle(SwitchToggleStyle(tint: Color.orange))
//
//								Divider()
//									.frame(height: 1)
//									.padding(.horizontal, 30)
//									.background(Color(hex: "#F68F54"))
//							}
//							.frame(maxWidth: .infinity, alignment: .leading)
//							.navigationBarHidden(true)
//							}
//						}

					}
					.frame(maxWidth: .infinity)
					.padding()

					Spacer()

					Button(action: {
						viewStore.send(.applyButtonTapped)
					}, label: {
						Text("Apply")
							.font(.custom("OpenSans-Regular", size: 15, relativeTo: .headline))
							.foregroundColor(.white)
							.frame(maxWidth: .infinity, alignment: .center)
							.padding()
							.background(Color(hex: "#F68F54"))
							.toggleStyle(SwitchToggleStyle(tint: Color(hex: "#F68F54")))
							.clipShape(Capsule())
					})
						.padding()

				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
			.onAppear {
				viewStore.send(.onAppear)
			}
		}
	}
}

struct SearchBarFiltterSectorsView_Previews: PreviewProvider {
	static var previews: some View {

		let store = Store(
			initialState: SearchBarFilterSectorsState(),
			reducer: sbFilterSectorsReducer, environment: ()
		)

		SearchBarFiltterSectorsView(store: store)
	}
}
