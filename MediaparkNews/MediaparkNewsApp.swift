//
//  MediaparkNewsApp.swift
//  MediaparkNews
//
//  Created by 19172093 on 05.01.2022.
//

import SwiftUI
import AppFeature
import ComposableArchitecture

@main
struct MediaparkNewsApp: App {

	let store: Store<AppState, AppAction> = Store(
		initialState: .init(),
		reducer: appReducer,
		environment: .live
	)

    var body: some Scene {
        WindowGroup {
			AppView(store: store)
        }
    }
}
