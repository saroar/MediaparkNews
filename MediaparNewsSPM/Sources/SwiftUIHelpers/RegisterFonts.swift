//
//  RegisterFonts.swift
//  
//
//  Created by 19172093 on 08.01.2022.
//

import UIKit

@discardableResult
public func registerFonts() -> Bool {
  [
	UIFont.registerFont(bundle: .module, fontName: "OpenSans-Regular", fontExtension: "ttf"),
	UIFont.registerFont(bundle: .module, fontName: "OpenSans-Bold", fontExtension: "ttf"),
	UIFont.registerFont(bundle: .module, fontName: "OpenSans-BoldItalic", fontExtension: "ttf"),
	UIFont.registerFont(bundle: .module, fontName: "OpenSans-ExtraBold", fontExtension: "ttf"),
	UIFont.registerFont(bundle: .module, fontName: "OpenSans-Italic", fontExtension: "ttf"),
	UIFont.registerFont(bundle: .module, fontName: "OpenSans-Semibold", fontExtension: "ttf"),
	UIFont.registerFont(bundle: .module, fontName: "Museosans-700italic", fontExtension: "ttf"),
  ]
  .allSatisfy { $0 }
}

extension UIFont {
  static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {
	guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
	  print("Couldn't find font \(fontName)")
	  return false
	}
	guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
	  print("Couldn't load data from the font \(fontName)")
	  return false
	}
	guard let font = CGFont(fontDataProvider) else {
	  print("Couldn't create font from data")
	  return false
	}

	var error: Unmanaged<CFError>?
	let success = CTFontManagerRegisterGraphicsFont(font, &error)
	guard success else {
	  print(
		"""
		Error registering font: \(fontName). Maybe it was already registered.\
		\(error.map { " \($0.takeUnretainedValue().localizedDescription)" } ?? "")
		"""
	  )
	  return true
	}

	return true
  }
}
