//
//  FeatureFlags.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import Foundation

enum FeatureFlag {
    case editMessage

    static subscript(flag: FeatureFlag) -> Bool {
        switch flag {
        case .editMessage: return false
        }
    }
}
