//
//  Shape+Extension.swift
//  MediaparkNews
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI

public struct RoundedCorner: Shape {
	var radius: CGFloat = .infinity
	var corners: UIRectCorner = .allCorners

	public init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
		self.radius = radius
		self.corners = corners
	}

	public func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		return Path(path.cgPath)
	}
}
