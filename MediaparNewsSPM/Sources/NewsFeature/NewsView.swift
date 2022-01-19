//
//  NewsView.swift
//  MediaparkNews
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI
import ComposableArchitecture
import SwiftUIHelpers
import ArticleDetailsFeature
import TopBarFeature
import NewsClient
import Models
import ArticleFeature
import IdentifiedCollections

public enum NewsRoute: Equatable {
	case articleDetails(ArticleDetailsState)

	public enum Tag: Int {
		case articleDetails
	}

	var tag: Tag {
		switch self {
		case .articleDetails:
			return .articleDetails
		}
	}
}

public struct NewsState: Equatable {
	public init(
		news: News = .init(),
		articles: IdentifiedArrayOf<Article> = [],
		topBarState: TopBarState = .live,
		route: NewsRoute? = nil
	) {
		self.news = news
		self.articles = articles
		self.topBarState = topBarState
		self.route = route
	}

	public var news: News = .init()
	public var articles: IdentifiedArrayOf<Article> = []
	public var route: NewsRoute?

	public var topBarState: TopBarState
	public var articleDetailsState: ArticleDetailsState? = nil
	public var isLoading = false

}

extension NewsState {
	static public var mock: NewsState = .init()

	static public var mockWithNews: NewsState = .init(
		news: News.mockWith3Articles
	)
}


public enum NewsAction {
	case onAppear
	case newsResponse(Result<News, NewsError>)
	case topBar(TopBarAction)

	case article(id: Article.ID, action: ArticleAction)

	case setNavigation(tag: NewsRoute.Tag?)
	case articleDetails(ArticleDetailsAction)
	case articleDetailsState(ArticleDetailsState)

}


public struct NewsEnvironment {

	public var mainQueue: AnySchedulerOf<DispatchQueue>
	public var newsClient: NewsClient

}

extension NewsEnvironment {
	static public var live: NewsEnvironment = .init(mainQueue: .main, newsClient: .live)

	static public var mock: NewsEnvironment = .init(mainQueue: .immediate, newsClient: .live)
}


public let newsReducer = Reducer<NewsState, NewsAction, NewsEnvironment>.combine(

	topBarReducer.pullback(
		state: \.topBarState,
		action: /NewsAction.topBar,
		environment: { _ in
			TopBarEnvironment.live
		}
	),

	articleDetailsReducer
		._pullback(
			state: (\NewsState.route).appending(path: /NewsRoute.articleDetails),
			action: /NewsAction.articleDetails,
			environment: { _ in () }
		),

	Reducer<NewsState, NewsAction, NewsEnvironment> { state, action, environment in

	switch action {
	case .onAppear:

		state.isLoading = true
		state.topBarState = TopBarState(isSearchBarActive: false)
		return environment.newsClient.news()
			.receive(on: environment.mainQueue.animation(.default))
			.catchToEffect()
			.map(NewsAction.newsResponse)

	case let .newsResponse(.success(newsResponse)):
		state.isLoading = false
		state.articles = .init(uniqueElements: newsResponse.articles)

		return .none
		
	case let .newsResponse(.failure(error)):
		state.isLoading = false
		// handle error hear
		return .none

	case .topBar(_):
		return .none

	case .articleDetails(_):

		return .none

	case .setNavigation(tag: .articleDetails):
		if let articleDetailsState = state.articleDetailsState {
			state.route = .articleDetails(articleDetailsState)
		}
		return .none

	case .setNavigation(tag: .none):
		state.route = .none
		state.articleDetailsState = nil
		return .none

	case let .articleDetailsState(adState):

		state.articleDetailsState = adState

		return Effect(value: NewsAction.setNavigation(tag: .articleDetails))
			.receive(on: DispatchQueue.main)
			.eraseToEffect()

	}
}).debug()

public struct NewsView: View {

	struct ViewState: Equatable {
		init(state: NewsState) {
			self.articles = state.articles
			self.tag = state.route?.tag
			self.isLoading = state.isLoading
		}

		let articles: IdentifiedArrayOf<Article>
		let tag: NewsRoute.Tag?
		let isLoading: Bool
	}

	let store: Store<NewsState, NewsAction>

	public init(store: Store<NewsState, NewsAction>) {
		self.store = store
	}

	public var body: some View {
		WithViewStore(store.scope(state: ViewState.init) ) { viewStore in

			VStack {

				TopBarView(
					store: store.scope(
						state: \.topBarState,
						action: NewsAction.topBar
					)
				)

				ScrollView {
					VStack {
						Text("News")
							.font(.custom(.openSansBold, size: 30))
							.frame(maxWidth: .infinity, alignment: .leading)

						ArticleListView(
							store: viewStore.isLoading
							? Store(initialState: NewsState.mockWithNews, reducer: .empty, environment: ())
							: self.store
						)
						.redacted(reason: viewStore.isLoading ? .placeholder : [])

					}
				}
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.navigationBarHidden(true)
			.background(Color(UIColor(hexString: "#E5E5E5")))
			.background(
				NavigationLink(
					destination: IfLetStore(
						self.store.scope(
							state: (\NewsState.route)
								.appending(path: /NewsRoute.articleDetails)
								.extract(from:),
							action: NewsAction.articleDetails
						),
						then: ArticleDetailsView.init(store:)
					),
					tag: NewsRoute.Tag.articleDetails,
					selection: viewStore.binding(
						get: \.tag,
						send: NewsAction.setNavigation(tag:)
					).animation()
				) {}

			)
		}

	}
}

struct NewsView_Previews: PreviewProvider {
	static var previews: some View {

		let store = Store(
			initialState: NewsState.mockWithNews,
			reducer: newsReducer,
			environment: NewsEnvironment.mock
		)

		VStack {
			NewsView(store: store)
			Spacer()
		}
		.background(Color.gray)

		VStack {
			NewsView(store: store)
			Spacer()
		}
		.previewDevice(PreviewDevice(rawValue: "iPhone 8"))
		.previewDisplayName("iPhone 8")
		.background(Color.gray)
	}
}

struct ArticleListView: View {

	let store: Store<NewsState, NewsAction>

	var body: some View {
		WithViewStore(self.store) { viewStore in
			ForEachStore(
				self.store.scope(state: \.articles, action: NewsAction.article)
			) { articleStore in
				WithViewStore(articleStore) { articleViewStore in
					Button {
						viewStore.send(.articleDetailsState(ArticleDetailsState(url: articleViewStore.state.url)))
					} label: {
						ArticleRowView(store: articleStore)
					}
					.buttonStyle(PlainButtonStyle())
				}
			}
		}
	}
}
