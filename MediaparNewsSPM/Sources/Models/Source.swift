//
//  Source.swift
//  
//
//  Created by 19172093 on 11.01.2022.
//

import Foundation

// MARK: - Source
public struct Source: Codable, Equatable, Hashable {
	public let name: String
	public let url: String
}

extension Source {
	static public var mockCnn: Source = .init(name: "CNN GREECE", url: "https://www.cnn.gr")
	static public var mockChinese: Source = .init(name: "大紀元時報-香港", url: "https://hk.epochtimes.com")
	static public var mockSwidesh: Source = .init(name: "Nyheter24", url: "https://nyheter24.se")
}
