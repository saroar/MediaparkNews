//
//  SwiftUIView.swift
//  
//
//  Created by 19172093 on 15.01.2022.
//

import SwiftUI
import SwiftUIHelpers
import Models
import ComposableArchitecture

public struct SortingByState: Equatable {
	public init(sortBys: IdentifiedArrayOf<Sorting.SearchIn> = .init(uniqueElements: Sorting.sortBys)) {
		self.sortBys = sortBys
	}


	public var sortBys: IdentifiedArrayOf<Sorting.SearchIn> = []
}

public enum SortingByAction {
	case sortBy(Sorting.SearchIn)
	case closeView
}

extension Array where Element: Equatable {
	@discardableResult
	public mutating func replace(_ element: Element, with new: Element) -> Bool {
		if let f = self.firstIndex(where: { $0 == element}) {
			self[f] = new
			return true
		}
		return false
	}
}
public let sortingByReducer = Reducer<SortingByState, SortingByAction, Void> { state, action, _ in
	switch action {
	case let .sortBy(item):

		guard let id = state.sortBys.filter({ $0.isOn == true }).first?.id else { return .none }

		state.sortBys[id: id]?.isOn.toggle()
		state.sortBys[id: item.id]?.isOn.toggle()

		return Effect(value: SortingByAction.closeView)
			.delay(for: 0.4,scheduler: DispatchQueue.main.animate(withDuration: 0.6))
			.eraseToEffect()

	case .closeView:
		return .none
	}
}

public struct SortingByView: View {
	public init(store: Store<SortingByState, SortingByAction>) {
		self.store = store
	}

	let store: Store<SortingByState, SortingByAction>

	public var body: some View {
		WithViewStore(store) { viewStore in
			VStack {

				Text("Sort By")
				Divider()

				ForEach(viewStore.sortBys) { item in
					HStack {
						Text(item.name)
						Spacer()
						Button(action: {
							viewStore.send(.sortBy(item))
						}, label: {
							if item.isOn {
								Circle()
									.strokeBorder(Color.init(hex: "#F78F54"), lineWidth: 6)
									.background(Circle().fill(Color.white))
									.frame(width: 24, height: 24)
							} else {
								Circle()
									.frame(width: 24, height: 24)
									.foregroundColor(Color.init(hex: "#F2F2F2"))
							}

						})
					}

					Divider()
				}

			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(Color(UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)))
			.cornerRadius(20, corners: [.topLeft, .topRight])
			.transition(.slide)
		}

	}
}

struct SortingByView_Previews: PreviewProvider {

	static var store = Store(
		initialState: SortingByState(),
		reducer: sortingByReducer,
		environment: ()
	)

	static var previews: some View {
		SortingByView(store: store)
	}
}

//struct FavoriteButton: View {
//	@Binding var isOn: Bool
//
//	var body: some View {
//		Button(action: {
//			isOn.toggle()
//		}, label: {
//			Image(systemName: "heart" + (isOn ? ".fill" : ""))
//		})
//	}
//}
// NEED FORbutton
struct ClearBackgroundView: UIViewRepresentable {
	func makeUIView(context: Context) -> some UIView {
		let view = UIView()
		DispatchQueue.main.async {
			view.superview?.superview?.backgroundColor = .clear
		}
		return view
	}
	func updateUIView(_ uiView: UIViewType, context: Context) {
	}
}

struct ClearBackgroundViewModifier: ViewModifier {

	func body(content: Content) -> some View {
		content
			.background(ClearBackgroundView())
	}
}

extension View {
	func clearModalBackground()->some View {
		self.modifier(ClearBackgroundViewModifier())
	}
}
