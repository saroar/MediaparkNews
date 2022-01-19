//
//  QueryHistory.swift
//  
//
//  Created by 19172093 on 11.01.2022.
//

import Foundation
import SwiftUI

public struct QueryHistory: Codable, Equatable, Hashable, Comparable {
	public static func < (lhs: QueryHistory, rhs: QueryHistory) -> Bool {
		return lhs.createdAt > rhs.createdAt
	}

	public let query: String
	public let createdAt: Date

	public init(query: String, createdAt: Date = Date()) {
		self.query = query
		self.createdAt = createdAt
	}
}

extension QueryHistory {
	static public let qh: QueryHistory = .init(query: "CCCP", createdAt: Date())
	static public let qh1: QueryHistory = .init(query: "USA", createdAt: Date())
	static public let qh2: QueryHistory = .init(query: "CCP", createdAt: Date())
}
