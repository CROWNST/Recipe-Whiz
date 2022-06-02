//
//  AutocompleteRecipe.swift
//  TinyChef
//
//  Created by David Hsieh on 1/5/22.
//

import Foundation

struct AutocompleteRecipe: Codable {
    let title: String
}

struct AutocompleteIngredient: Codable {
    let name: String
}
