//
//  Font+Extension.swift
//  MediaparkNews
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI

extension Font {
	struct Event {
		let name = Font.custom("GillSans-UltraBold", size: 14)
		let location = Font.custom("GillSans-SemiBold", size: 10)
		let date = Font.custom("GillSans-UltraBold", size: 16)
		let price = Font.custom("GillSans-SemiBoldItalic", size: 12)
	}
	static let event = Event()
}
