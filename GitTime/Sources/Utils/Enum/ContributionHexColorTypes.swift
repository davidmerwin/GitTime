//
//  ContributionHexColorTypes.swift
//  GitTime
//
//  Created by Kanz on 2020/10/30.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import Foundation

/*
 --color-calendar-graph-day-bg: #ebedf0,
     --color-calendar-graph-day-L1-bg: #9be9a8,
     --color-calendar-graph-day-L2-bg: #40c463,
     --color-calendar-graph-day-L3-bg: #30a14e,
     --color-calendar-graph-day-L4-bg: #216e39,
 */

/* Halloween
--color-calendar-halloween-graph-day-L1-bg: #ffee4a;
	--color-calendar-halloween-graph-day-L2-bg: #ffc501;
	--color-calendar-halloween-graph-day-L3-bg: #fe9600;
	--color-calendar-halloween-graph-day-L4-bg: #03001c;
*/
enum ContributionHexColorTypes: String, CaseIterable {
    case level0
    case level1
    case level2
    case level3
    case level4
	
	case halloweenLevel1
	case halloweenLevel2
	case halloweenLevel3
	case halloweenLevel4

    var fill: String {
        switch self {
        case .level0:
            return "var(--color-calendar-graph-day-bg)"
        case .level1:
            return "var(--color-calendar-graph-day-L1-bg)"
        case .level2:
            return "var(--color-calendar-graph-day-L2-bg)"
        case .level3:
            return "var(--color-calendar-graph-day-L3-bg)"
        case .level4:
            return "var(--color-calendar-graph-day-L4-bg)"
		case .halloweenLevel1:
			return "var(--color-calendar-halloween-graph-day-L1-bg)"
		case .halloweenLevel2:
			return "var(--color-calendar-halloween-graph-day-L2-bg)"
		case .halloweenLevel3:
			return "var(--color-calendar-halloween-graph-day-L3-bg)"
		case .halloweenLevel4:
			return "var(--color-calendar-halloween-graph-day-L4-bg)"
		}
    }
    
    var hexString: String {
        switch self {
        case .level0:
            return "ebedf0"
        case .level1:
            return "9be9a8"
        case .level2:
            return "40c463"
        case .level3:
            return "30a14e"
        case .level4:
            return "216e39"
		case .halloweenLevel1:
			return "ffee4a"
		case .halloweenLevel2:
			return "ffc501"
		case .halloweenLevel3:
			return "fe9600"
		case .halloweenLevel4:
			return "03001c"
		}
    }
}
