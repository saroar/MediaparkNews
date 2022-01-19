//
//  ArticleRowView.swift
//  
//
//  Created by 19172093 on 10.01.2022.
//

import SwiftUI
import SwiftUIHelpers
import ComposableArchitecture
import Models

public enum  ArticleAction {
}

public struct ArticleEnvironment {
	public init() {}
}

public let articleReduducer = Reducer<Article, ArticleAction, Void> { article, action, _ in
	switch action {}
}

public struct ArticleRowView: View {
	public init(store: Store<Article, ArticleAction>) {
		self.store = store
	}

	let store: Store<Article, ArticleAction>

	public var body: some View {

		WithViewStore(store) { item in
			HStack {
				if #available(iOS 15.0, *) {
					AsyncImage(
						url: URL(string: item.image),
						content: { image in
							image.resizable()
								.frame(width: UIScreen.main.bounds.width * 0.33)
								.aspectRatio(contentMode: .fit)
						},
						placeholder: {
							ProgressView()
								.frame(width: UIScreen.main.bounds.width * 0.33)
								.aspectRatio(contentMode: .fit)
						}
					)
				} else {
					// Fallback on earlier versions
					Image(systemName: "person")
						.frame(width: 124, height: 108)
						.background(Color.red)
				}


				VStack {
					Text(item.title)
						.frame(maxWidth: .infinity, alignment: .leading)
						.font(.custom("OpenSans-Semibold", size: 15, relativeTo: .title))
						.lineLimit(2)
						.foregroundColor(Color(hex: "#1E1F21"))
						.padding(.bottom, 3)
					Text(item.articleDescription)
						.frame(maxWidth: .infinity, alignment: .leading)
						.font(.custom("OpenSans-Regular", size: 12, relativeTo: .headline))
						.lineLimit(2)
						.foregroundColor(Color(hex: "#1E1F21"))

				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()

			}
			.frame(height: 108)
			.background(Color.white)
			.padding(.top, 10)
				}

	}
}
