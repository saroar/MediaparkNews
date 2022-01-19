//
//  NewsError.swift
//  
//
//  Created by 19172093 on 13.01.2022.
//

import Foundation

public enum NewsError: Error, Hashable, Equatable {
	case message(String)
}

extension NewsError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case let .message(message):
			return message
		}
	}
}
