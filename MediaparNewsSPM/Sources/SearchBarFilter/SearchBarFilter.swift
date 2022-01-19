//
//  SwiftUIView.swift
//  
//
//  Created by 19172093 on 11.01.2022.
//

import SwiftUI
import ComposableArchitecture
import SwiftUIHelpers
import SearchBarFilterSectors
import TcaHelpers
import Models
import UserDefaultsClient

extension UserDefaults {
	@UserDefaultPublished(UserDefaultKeys.sorting.rawValue, defaultValue: Sorting())
	public static var sorting: Sorting
}

public class UserDefaultsClient {
	public static var sortingPublisher: Effect<Sorting, Never> {
		UserDefaults.$sorting.eraseToEffect()
	}
}

public enum SearchBarFilterRoute: Equatable {
	case sectors(SearchBarFilterSectorsState)

	public enum Tag: Int {
		case sectors
	}

	var tag: Tag {
		switch self {
		case .sectors:
			return .sectors
		}
	}
}

public struct SearchBarFilterState: Equatable {
	public init(
		showToDatePicker: Bool = false,
		showFromDatePicker: Bool = false,
		savedToDate: Date? = nil,
		savedFromDate: Date? = nil,
		selectedDate: Date = Date(),
		isClearAllFilterDataButtonTapped: Bool = false,
		route: SearchBarFilterRoute? = nil
	) {
		self.showToDatePicker = showToDatePicker
		self.showFromDatePicker = showFromDatePicker
		self.savedToDate = savedToDate
		self.savedFromDate = savedFromDate
		self.selectedDate = selectedDate
		self.isClearAllFilterDataButtonTapped = isClearAllFilterDataButtonTapped
		self.route = route
	}

	public var showToDatePicker: Bool = false
	public var showFromDatePicker: Bool = false
	public var savedToDate: Date? = nil
	public var savedFromDate: Date? = nil
	public var selectedDate: Date = Date()
	public var isClearAllFilterDataButtonTapped = false
	public var route: SearchBarFilterRoute?
}


public enum SearchBarFilterAction {
	case onAppear
	case setNavigation(tag: SearchBarFilterRoute.Tag?)
	case searchBarFilerSeactors(SearchBarFilterSectorsAction)

	case showToDatePicker(Bool)
	case showFromDatePicker(Bool)
	case savedToDate(Date?)
	case savedFromDate(Date?)
	case isClearAllFilterDataButtonTapped
	case applyFilterButtonTapped
	case searchFilterResponse(Result<Sorting, Never>)
}


public let searchBarFilterReducer = Reducer<SearchBarFilterState, SearchBarFilterAction, Void>.combine(
	sbFilterSectorsReducer
		._pullback(
			state: (\SearchBarFilterState.route)
				.appending(path: /SearchBarFilterRoute.sectors),
			action: /SearchBarFilterAction.searchBarFilerSeactors,
			environment: { _ in () }
		),
	.init { state, action, _ in
		switch action {
		case .onAppear:

			return UserDefaultsClient
				.sortingPublisher
				.receive(on: DispatchQueue.main)
				.catchToEffect(SearchBarFilterAction.searchFilterResponse)

		case .setNavigation(tag: .sectors):
			state.route = .sectors(.init())
			return .none

		case .setNavigation(tag: .none):
			state.route = .none
			return .none

		case .searchBarFilerSeactors(_):
			return .none

		case let .showToDatePicker(boolValue):
			state.showToDatePicker = boolValue
			return .none

		case let .showFromDatePicker(boolValue):
			state.showFromDatePicker = boolValue
			return .none

		case let .savedToDate(date):
			state.savedToDate = date
			return .none

		case let .savedFromDate(date):
			state.savedFromDate = date
			return .none

		case .isClearAllFilterDataButtonTapped:
			state.savedFromDate = nil
			state.savedToDate = nil
			return .none

		case .applyFilterButtonTapped:

			var sorting = UserDefaults.sorting
			sorting.from = state.savedFromDate?.getFormattedDate()
			sorting.to = state.savedToDate?.getFormattedDate()
			UserDefaults.sorting = sorting

			return .none

		case let .searchFilterResponse(.success(result)):

			state.savedToDate = result.from?.toDate()
			state.savedFromDate = result.to?.toDate()

			return .none
		}
})

public struct SearchBarFilterView: View {

	struct ViewState: Equatable {
		init(state: SearchBarFilterState) {
			self.showToDatePicker = state.showToDatePicker
			self.showFromDatePicker = state.showFromDatePicker
			self.savedToDate = state.savedToDate
			self.savedFromDate = state.savedFromDate
			self.selectedDate = state.selectedDate
			self.isClearAllFilterDataButtonTapped = state.isClearAllFilterDataButtonTapped
			self.tag = state.route?.tag
		}

		let showToDatePicker: Bool
		let showFromDatePicker: Bool
		let savedToDate: Date?
		let savedFromDate: Date?
		let selectedDate: Date
		let isClearAllFilterDataButtonTapped: Bool
		let tag: SearchBarFilterRoute.Tag?
	}

	@Environment(\.presentationMode) var presentationMode

	public let store: Store<SearchBarFilterState, SearchBarFilterAction>

	public init(store: Store<SearchBarFilterState, SearchBarFilterAction>) {
		self.store = store
	}

	public var body: some View {
		WithViewStore(self.store.scope(state: ViewState.init)) { viewStore in
			ZStack {

				if viewStore.showToDatePicker {
					DatePickerWithButtons(
						showDatePicker: viewStore.binding(
							get: \.showToDatePicker,
							send: SearchBarFilterAction.showToDatePicker
						),
						savedDate: viewStore.binding(
							get: \.savedToDate,
							send: SearchBarFilterAction.savedToDate
						),
						selectedDate: viewStore.savedToDate ?? Date()
					)
					.animation(.easeOut)
					.zIndex(99)
					.background(Color.white)

				}

				if viewStore.showFromDatePicker {
					DatePickerWithButtons(
						showDatePicker: viewStore.binding(
							get: \.showFromDatePicker,
							send: SearchBarFilterAction.showFromDatePicker
						),
						savedDate: viewStore.binding(
							get: \.savedFromDate,
							send: SearchBarFilterAction.savedFromDate
						),
						selectedDate: viewStore.savedFromDate ?? Date()
					)
					.animation(.easeOut)
					.zIndex(99)
					.background(Color.white)
				}

				VStack {

					//TopBar
					HStack {
					
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Image(systemName: "arrow.left")
						})
							.padding(.leading)

						Spacer()

						Text("Logo")
							.font(.largeTitle).italic().bold()
							.foregroundColor(Color(hex: "#F68F54"))
							.padding(.leading, 20)

						Spacer()

						Button(action: {
							viewStore.send(.isClearAllFilterDataButtonTapped)
						}, label: {
							Text("Clear")
								.font(.custom("OpenSans-Semibold", size: 14, relativeTo: .headline))
							Image(systemName: "trash")
						})
							.padding(.trailing)

					}
					.accentColor((Color(hex: "#F68F54")))

					VStack {
						Text("Filter")
							.font(.custom("OpenSans-Bold", size: 16, relativeTo: .headline))
							.frame(maxWidth: .infinity, alignment: .leading)

						Text("Date")
							.font(.custom("OpenSans-SemiBold", size: 14, relativeTo: .headline))
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.vertical, 10)

						VStack {
							Text("From")
								.font(.custom("OpenSans-SemiBold", size: 10, relativeTo: .headline))
								.frame(maxWidth: .infinity, alignment: .leading)
								.foregroundColor(Color(hex: "#F68F54"))

							Button(action: {
								withAnimation {
									viewStore.send(.showFromDatePicker(true))
								}
							}, label: {
								HStack {
									Text(viewStore.savedFromDate?.getFormattedDate() ?? "yyyy/mm/dd")
										.font(.custom("OpenSans-SemiBold", size: 10, relativeTo: .headline))
										.frame(maxWidth: .infinity, alignment: .leading)
										.foregroundColor(viewStore.savedFromDate == nil ? Color.init(hex: "#939DAE") : Color.black )

									Image(systemName: "calendar")
								}
								.padding(.vertical)
							}
							)

							Divider()
								.frame(height: 1)
								.padding(.horizontal, 30)
								.background(Color(hex: "#F68F54"))
						}
						.frame(maxWidth: .infinity, alignment: .leading)


						VStack {
							Text("To")
								.font(.custom("OpenSans-SemiBold", size: 10, relativeTo: .headline))
								.frame(maxWidth: .infinity, alignment: .leading)
								.foregroundColor(Color(hex: "#F68F54"))
								.padding(.top)

							Button(action: {
								withAnimation {
									viewStore.send(.showToDatePicker(true))
								}
							}, label: {
								HStack {
									Text(viewStore.savedToDate?.getFormattedDate() ?? "yyyy/mm/dd")
										.font(.custom("OpenSans-SemiBold", size: 10, relativeTo: .headline))
										.frame(maxWidth: .infinity, alignment: .leading)
										.foregroundColor(viewStore.savedToDate == nil ? Color.init(hex: "#939DAE") : Color.black )

									Image(systemName: "calendar")
								}
								.padding(.vertical)
							}
							)

							Divider()
								.frame(height: 1)
								.padding(.horizontal, 30)
								.background(Color(hex: "#F68F54"))
						}
						.frame(maxWidth: .infinity, alignment: .leading)

						VStack {

							NavigationLink(
								destination: IfLetStore(
									self.store.scope(
										state: (\SearchBarFilterState.route)
											.appending(path: /SearchBarFilterRoute.sectors)
											.extract(from:),
										action: SearchBarFilterAction.searchBarFilerSeactors
									),
									then: SearchBarFiltterSectorsView.init(store:)
								),
								tag: SearchBarFilterRoute.Tag.sectors,
								selection: viewStore.binding(
									get: \.tag,
									send: SearchBarFilterAction.setNavigation(tag:)
								).animation()
							) {
								HStack {
									Text("Search in")
										.font(.custom("OpenSans-Bold", size: 14, relativeTo: .headline))
										.frame(maxWidth: .infinity, alignment: .leading)

									Spacer()

									Text("All")
										.font(.custom("OpenSans-Bold", size: 14, relativeTo: .headline))
										.foregroundColor(Color(#colorLiteral(red: 0.5731949806, green: 0.6159132123, blue: 0.6847787499, alpha: 1)))
								}
								.padding(.vertical)
							}

							Divider()
								.frame(height: 1)
								.padding(.horizontal, 30)
								.background(Color(hex: "#F68F54"))
						}
						.frame(maxWidth: .infinity, alignment: .leading)


					}
					.frame(maxWidth: .infinity)
					.padding()

					Spacer()

					Button(action: {
						// save all changes
						viewStore.send(.applyFilterButtonTapped)
					}, label: {
						Text("Apply filter")
							.font(.custom("OpenSans-Regular", size: 15, relativeTo: .headline))
							.foregroundColor(.white)
							.frame(maxWidth: .infinity, alignment: .center)
							.padding()
							.background(Color(hex: "#F68F54"))
							.clipShape(Capsule())
					})
						.padding()

				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
			.onAppear {
				viewStore.send(.onAppear)
			}
			.navigationBarHidden(true)
		}
	}
}

struct SearchBarFilterView_Previews: PreviewProvider {
	static var previews: some View {

		let store = Store(
			initialState: SearchBarFilterState(),
			reducer: searchBarFilterReducer,
			environment: ()
		)

		SearchBarFilterView(store: store)
	}
}

struct DatePickerWithButtons: View {

	@Binding var showDatePicker: Bool
	@Binding var savedDate: Date?
	@State var selectedDate: Date = Date()

	var body: some View {
		ZStack {

			VStack {
				DatePicker("", selection: $selectedDate, displayedComponents: .date)
					.datePickerStyle(GraphicalDatePickerStyle())
					.padding()

				Divider()
				HStack {
					Button(action: {
						withAnimation {
							showDatePicker = false
						}
					}, label: {
						Text("Cancel")
					})

					Spacer()

					Button(action: {
						withAnimation {
							savedDate = selectedDate
							showDatePicker = false
						}
					}, label: {
						Text("Save".uppercased())
							.bold()
					})
				}
				.padding()

			}
			.background(
				Color.white
					.cornerRadius(30)
					.overlay(
						RoundedRectangle(cornerRadius: 30)
							.stroke(lineWidth: 0.2)
					)
					.shadow(color: .black.opacity(0.5), radius: 30, x: 2, y: 2)
			)

			.padding()


		}
	}
}
