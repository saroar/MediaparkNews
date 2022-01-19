//
//  View+Extension.swift
//  MediaparkNews
//
//  Created by 19172093 on 06.01.2022.
//

import SwiftUI

extension View {
	public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		clipShape( RoundedCorner(radius: radius, corners: corners) )
	}
}

extension View {
  @ViewBuilder public func stackNavigationViewStyle() -> some View {
	if #available(iOS 15.0, *) {
	  self.navigationViewStyle(.stack)
	} else {
	  self.navigationViewStyle(StackNavigationViewStyle())
	}
  }
}
