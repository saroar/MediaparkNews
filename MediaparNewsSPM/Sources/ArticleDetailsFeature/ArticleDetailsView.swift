//
//  ArticleDetailsView.swift
//  
//
//  Created by 19172093 on 09.01.2022.
//

import SwiftUI
import SwiftUIHelpers
import ComposableArchitecture

public struct ArticleDetailsState: Equatable {
	public init(
		webViewStore: WebViewStore = WebViewStore(),
		url: String = ""
	) {
		self.webViewStore = webViewStore
		self.url = url
	}

	var webViewStore = WebViewStore()
	var url: String = ""
}

public enum ArticleDetailsAction {
	case goBack
	case goForward
}

public let articleDetailsReducer = Reducer<ArticleDetailsState, ArticleDetailsAction, Void> { state, action, _ in
	switch action {
	case .goBack:
		state.webViewStore.webView.goBack()
		return .none
	case .goForward:
		state.webViewStore.webView.goForward()
		return .none
	}
}

public struct ArticleDetailsView: View {

	@Environment(\.presentationMode) var presentationMode
	let store: Store<ArticleDetailsState, ArticleDetailsAction>

	public init(store: Store<ArticleDetailsState, ArticleDetailsAction>) {
		self.store = store
	}

	public var body: some View {
		WithViewStore(store) { viewStore in
			NavigationView {
				WebView(webView: viewStore.webViewStore.webView)
					.navigationBarItems(
						leading: HStack {
							Button(action: {
								presentationMode.wrappedValue.dismiss()
							}) {
								Image(systemName: "xmark.circle")
									.imageScale(.large)
									.aspectRatio(contentMode: .fit)
									.frame(width: 32, height: 32)
							}
						}
					)
					.navigationBarTitle(Text(verbatim: viewStore.webViewStore.title ?? "") , displayMode: .inline)
					.navigationBarItems(trailing: HStack {
						Button(action: {
							viewStore.send(.goBack)
						}) {
							Image(systemName: "chevron.left")
								.imageScale(.large)
								.aspectRatio(contentMode: .fit)
								.frame(width: 32, height: 32)
						}.disabled(!viewStore.webViewStore.canGoBack)

						if viewStore.webViewStore.isLoading {
							ProgressView()
								.progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#1E1F21")))
								.font(.largeTitle)

						}

						Button(action: {
							viewStore.send(.goForward)
						}) {
							Image(systemName: "chevron.right")
								.imageScale(.large)
								.aspectRatio(contentMode: .fit)
								.frame(width: 32, height: 32)
						}.disabled(!viewStore.webViewStore.canGoForward)

					})
			}.onAppear {
				viewStore.webViewStore.webView.load(URLRequest(url: URL(string: viewStore.url)!))
			}

		}
		.navigationBarHidden(true)
	}
}

//struct ArticleDetailsView_Previews: PreviewProvider {
//	static var previews: some View {
//		NavigationView {
//			ArticleDetailsView(url: "https://www.cnn.gr/kosmos/story/296673/meta-ti-metallaxi-omikron-tha-prepei-na-mathoyme-na-zoyme-me-ton-koronoio")
//		}
//	}
//}
