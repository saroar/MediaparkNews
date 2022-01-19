//
//  File.swift
//  
//
//  Created by 19172093 on 11.01.2022.
//

import Foundation
import SwiftUI

public struct Sorting: Codable ,Equatable {
	public var parameters: Parameters = .in
	public var searchIn: [SearchIn] = SearchIn.searchInKeys
	public var from: String? = nil
	public var to: String? = nil
	public var sortBy: SortBy = .uploadDate

	public init(
		filter: Parameters = .in,
		sortBy: SortBy = .uploadDate
	) {
		self.parameters = filter
		self.sortBy = sortBy
	}

	public enum Parameters: String, CaseIterable, Codable {
		case q, publishedAt, sortby, from, to, `in` = "Search in"
	}

	public struct SearchIn: Codable, Equatable, Hashable, Identifiable {

		public var id: UUID
		public var name: String
		public var isOn: Bool

		public init(
			id: UUID,
			name: String,
			isOn: Bool
		) {
			self.id = id
			self.name = name
			self.isOn = isOn
		}
	}

	public enum SortBy: String, Codable {
		case publishedAt
		case uploadDate = "Upload Date"
		case relevance = "Relevance"
	}
}

extension Sorting.SearchIn {
	public static let searchInKey: Sorting.SearchIn = .init(id: UUID(), name: "title", isOn: true)
	public static let searchInKey1: Sorting.SearchIn = .init(id: UUID(), name: "description", isOn: true)
	public static let searchInKey2: Sorting.SearchIn = .init(id: UUID(), name: "content", isOn: false)
	public static var searchInKeys: [Sorting.SearchIn] = [searchInKey, searchInKey1, searchInKey2]
}

extension Sorting {
	public static let sortBy: Sorting.SearchIn = .init(id: UUID(), name: SortBy.uploadDate.rawValue, isOn: true)
	public static let sortBy1: Sorting.SearchIn = .init(id: UUID(), name: SortBy.relevance.rawValue, isOn: false)

	public static var sortBys: [Sorting.SearchIn] = [sortBy, sortBy1]
}
