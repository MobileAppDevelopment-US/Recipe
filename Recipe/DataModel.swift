//
//  DataModel.swift
//  Recipe
//
//  Created by User on 04.05.17.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation

class DataModel{
    var image: String
    var title: String!
    var ingredients: String!
    var urlSite: String!
    
    init(withDictionary: NSDictionary) {
        self.title = withDictionary.object(forKey: "title") as! String
        self.ingredients = withDictionary.object(forKey: "ingredients") as! String
        self.image = withDictionary.object(forKey: "thumbnail") as! String
        self.urlSite = withDictionary.object(forKey: "href") as! String
    }
    
}
