//
//  Fonts.swift
//  
//
//  Created by 19172093 on 08.01.2022.
//

import SwiftUI
import Tagged

public typealias FontName = Tagged<Font, String>

extension FontName {
	public static let openSans: Self = "OpenSans-Regular"
	public static let openSansBold: Self = "OpenSans-Bold"
	public static let openSansBoldInalic: Self = "OpenSans-BoldItalic"
	public static let openSansExtraBold: Self = "OpenSans-ExtraBold"
	public static let openSansItalic: Self = "OpenSans-Italic"
	public static let openSansSemibold: Self = "OpenSans-Semibold"
	public static let museosansItalic: Self = "Museosans-700italic"
}

extension Font {
  public static func custom(_ name: FontName, size: CGFloat) -> Self {
	.custom(name.rawValue, size: size)
  }
}

#if DEBUG
  struct Font_Previews: PreviewProvider {
	static var previews: some View {
	  registerFonts()

	  return VStack(alignment: .leading, spacing: 12) {
		ForEach(
		  [10, 12, 14, 16, 18, 20, 24, 32, 60].reversed(),
		  id: \.self
		) { fontSize in
		  Text("Today’s daily challenge")
			.font(.custom(.museosansItalic, size: 30))
		}
	  }
	}
  }
#endif
