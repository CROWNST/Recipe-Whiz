//
//  SearchRecipe.swift
//  TinyChef
//
//  Created by David Hsieh on 1/6/22.
//

import Foundation

struct SearchRecipeResponse: Codable {
    let results: [SearchRecipe]
    let baseUri: String
}

struct SearchRecipe: Codable {
    let id, readyInMinutes, servings: Int
    let title: String
    let image: String?
}

struct SearchRecipeComplexResponse: Codable {
    let results: [SearchRecipeComplex]
}

struct SearchRecipeComplex: Codable {
    let vegetarian, vegan, glutenFree, dairyFree: Bool
    let title: String
    let image: String?
    let readyInMinutes, servings, id: Int
    let missedIngredientCount: Int?
    let missedIngredients, usedIngredients: [Ingredient]?
    let analyzedInstructions: [StepsSection]
}

struct Ingredient: Codable {
    let original: String
}

struct StepsSection: Codable {
    let name: String
    let steps: [Step]
}

struct Step: Codable {
    let number: Int
    let step: String
}


