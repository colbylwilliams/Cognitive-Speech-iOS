//
//  Color.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/16/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit

enum Color {
	
	case primary
	case primaryDark
	case primaryLight
	case tint
	case accent
	case primaryText
	case secondaryText
	case divider
	
	var name: String {
		switch self {
		case .primary:
			return "c_primary"
		case .primaryDark:
			return "c_primary_dark"
		case .primaryLight:
			return "c_primary_light"
		case .tint:
			return "c_tint"
		case .accent:
			return "c_accent"
		case .primaryText:
			return "c_primary_text"
		case .secondaryText:
			return "c_secondary_text"
		case .divider:
			return "c_divider"
		}
	}
	
	var uiColor: UIColor? {
		return UIColor(named: self.name)
	}
	
	var cgColor: CGColor? {
		return uiColor?.cgColor
	}
}
