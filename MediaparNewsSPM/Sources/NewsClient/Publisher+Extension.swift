//
//  Publisher+Extension.swift
//  
//
//  Created by 19172093 on 09.01.2022.
//

import Foundation
import Combine
import Models

public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == NewsError {

	func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), NewsError> {
		tryMap { (data: Data, response: URLResponse) in
			guard let http = response as? HTTPURLResponse else { throw NewsError.message("Non-HTTP response received") }
			return (data, http)
		}
		.mapError { error in
			if error is NewsError {
				return error as! NewsError
			} else {
				return NewsError.message("Network error \(error)")
			}
		}
		.eraseToAnyPublisher()
	}

}

public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == NewsError {
	func responseData() -> AnyPublisher<Data, NewsError> {
		tryMap { (data: Data, response: HTTPURLResponse) -> Data in
			switch response.statusCode {
			case 200...299: return data
			case 400...499: throw NewsError.message("\(#line) error with status code: \(response.statusCode)")
			case 500...599: throw NewsError.message("\(#line) error with status code: \(response.statusCode)")
			default:
				throw NewsError.message("\(#line) error with status code: \(response.statusCode)")
			}
		}
		.mapError { $0 as! NewsError }
		.eraseToAnyPublisher()
	}
}

public extension Publisher where Output == (data: Data, response: URLResponse) {

	func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), NewsError> {
		tryMap { (data: Data, response: URLResponse) in
			guard let http = response as? HTTPURLResponse else { throw NewsError.message("Non-HTTP response received") }
			return (data, http)
		}
		.mapError { error in
			if error is NewsError {
				return error as! NewsError
			} else {
				return NewsError.message("Network error \(error)")
			}
		}
		.eraseToAnyPublisher()
	}

}


public extension Publisher where Output == Data, Failure == NewsError {
	func decoding<D: Decodable, Decoder: TopLevelDecoder>(
		_ type: D.Type,
		decoder: Decoder
	) -> AnyPublisher<D, NewsError> where Decoder.Input == Data {
		decode(type: D.self, decoder: decoder)
			.mapError { error in
				if error is DecodingError {
					return NewsError.message("decodingError \(error as! DecodingError)")
				} else {
					return error as! NewsError
				}

			}
			.eraseToAnyPublisher()
	}
}
