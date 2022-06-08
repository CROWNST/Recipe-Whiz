//
//  SearchRecipeModel.swift
//  TinyChef
//
//  Created by David Hsieh on 1/7/22.
//

import Foundation
import UIKit

class RecipeComplexModel {
    static var recipes = [SearchRecipeComplex]()
    static var images = [UIImage?]()
    static var imageDataTasks = [URLSessionDataTask?]()
}

class RecipeComplexModelIngredients {
    static var recipes = [SearchRecipeComplex]()
    static var images = [UIImage?]()
    static var imageDataTasks = [URLSessionDataTask?]()
}

class ChosenRecipes {
    static var recipes = [RecipeCardInfo]()
}
