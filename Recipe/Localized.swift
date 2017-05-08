//
//  Localized.swift
//  Recipe
//
//  Created by User on 06.05.17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

extension String {
    
    //MARK: Localized
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

class Localized: NSObject {
}
