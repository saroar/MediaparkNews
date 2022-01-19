//
//  File.swift
//  
//
//  Created by 19172093 on 12.01.2022.
//

import Foundation

extension Date {
	public func getFormattedDate(format: String? = "yyyy-MM-dd") -> String {
		let dateformat = DateFormatter()
		dateformat.dateFormat = format
		return dateformat.string(from: self)
	}
}
