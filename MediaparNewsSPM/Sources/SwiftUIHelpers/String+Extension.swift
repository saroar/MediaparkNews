//
//  String+Extension.swift
//  
//
//  Created by 19172093 on 17.01.2022.
//

import Foundation

extension String {

	public func toDate(withFormat format: String? = "yyyy-MM-dd") -> Date? {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = NSTimeZone.local
		dateFormatter.locale = Locale.current
		dateFormatter.calendar = Calendar(identifier: .gregorian)
		dateFormatter.dateFormat = format
		let date = dateFormatter.date(from: self)

		return date

	}

	public func stringByAddingPercentEncodingForRFC3986() -> String? {
		let unreserved = "-._~/?"
		let allowed = NSMutableCharacterSet.alphanumeric()
		allowed.addCharacters(in: unreserved)
		return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
	}
}
