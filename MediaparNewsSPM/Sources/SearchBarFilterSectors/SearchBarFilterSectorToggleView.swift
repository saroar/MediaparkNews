//
//  SearchBarFilterSectorToggleView.swift
//  
//
//  Created by 19172093 on 13.01.2022.
//

import SwiftUI
import ComposableArchitecture
import Models

public enum SearchBarFilterSectorToggleAction {
	case togglePressed(isOn: Bool)
}

public let searchFilterSectorToggleReducer = Reducer<
	Sorting.SearchIn, SearchBarFilterSectorToggleAction, Void
> { state, action, _ in
	switch action {

	case .togglePressed(isOn: let isOn):
		withAnimation {
			state.isOn.toggle()
		}
		return .none
	}
}

extension Sorting.SearchIn {
	var view: SearchBarFilterSectorToggleView.ViewState {
		SearchBarFilterSectorToggleView.ViewState(state: self)
	}
}

extension SearchBarFilterSectorToggleAction {
	init(action: SearchBarFilterSectorToggleView.ViewAction) {
		switch action {
		case .togglePressed(isOn: let isOn):
			self = .togglePressed(isOn: isOn)
		}
	}
}

struct SearchBarFilterSectorToggleView: View {

	struct ViewState: Equatable {
		init(state: Sorting.SearchIn) {
			self.id = state.id
			self.name = state.name
			self.isOn = state.isOn
		}

		public var id: UUID
		public var name: String
		public var isOn: Bool
	}


	public init(store: Store<Sorting.SearchIn, SearchBarFilterSectorToggleAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store.scope(state: ViewState.init))
	}

	let store: Store<Sorting.SearchIn, SearchBarFilterSectorToggleAction>
	@ObservedObject var viewStore: ViewStore<ViewState, SearchBarFilterSectorToggleAction>


	enum  ViewAction {
		case togglePressed(isOn: Bool)
	}


	var body: some View {
		VStack {
			Toggle(
				isOn: viewStore.binding(
					get: \.isOn,
					send: SearchBarFilterSectorToggleAction.togglePressed(isOn:)
				)
			) {
				Text(viewStore.name.capitalized)
					.font(.custom("OpenSans-SemiBold", size: 14, relativeTo: .headline))
					.frame(maxWidth: .infinity, alignment: .leading)
					.foregroundColor(Color.black)
			}
			.toggleStyle(SwitchToggleStyle(tint: Color.orange))

			Divider()
				.frame(height: 1)
				.padding(.horizontal, 30)
				.background(Color(hex: "#F68F54"))
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.navigationBarHidden(true)
	}
}
