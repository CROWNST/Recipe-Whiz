//
//  RecipeCardInfo.swift
//  TinyChef
//
//  Created by David Hsieh on 1/15/22.
//

import Foundation
import UIKit

struct RecipeCardInfo {
    
    let image: UIImage
    let id: Int
    let title, info: String
    let instructions: String
    let specialInstructions: NSMutableAttributedString?
    
    static func info(readyInMinutes: Int, servings: Int, vegetarian: Bool, vegan: Bool, glutenFree: Bool, dairyFree: Bool) -> String {
        var result = "⏱ \(readyInMinutes) min 🍽 \(servings) serving\n"
        if vegetarian {
            result += "vegetarian "
        }
        if vegan {
            result += "vegan "
        }
        if glutenFree {
            result += "glutenFree "
        }
        if dairyFree {
            result += "dairyFree"
        }
        return result
    }
    
    static func instructions(ingredients: [Ingredient], analyzedInstructions: [StepsSection]) -> String {
        var result = "Ingredients:\n"
        for ingredient in ingredients {
            result += "\(ingredient.original)\n"
        }
        result += "Instructions:\n"
        for stepsSection in analyzedInstructions {
            result += (stepsSection.name == "" ? "" : "\(stepsSection.name)\n")
            for step in stepsSection.steps {
                result += "\(step.number). \(step.step)\n"
            }
        }
        return result
    }
    
    static func specialInstructions(missedIngredientCount: Int, missedIngredients: [Ingredient], usedIngredients: [Ingredient], analyzedInstructions: [StepsSection]) -> NSMutableAttributedString {
        var attributes = [NSMutableAttributedString.Key : AnyObject]()
        attributes[.foregroundColor] = UIColor.systemYellow
        let result = NSMutableAttributedString(string: "\(missedIngredientCount) missing ingredients:\n", attributes: attributes)
        for ingredient in missedIngredients {
            result.append(NSMutableAttributedString(string: "\(ingredient.original)\n", attributes: attributes))
        }
        result.append(NSMutableAttributedString(string: "Used ingredients:\n", attributes: nil))
        for ingredient in usedIngredients {
            result.append(NSMutableAttributedString(string: "\(ingredient.original)\n", attributes: nil))
        }
        result.append(NSMutableAttributedString(string: "Instructions:\n", attributes: nil))
        for stepsSection in analyzedInstructions {
            result.append(stepsSection.name == "" ? NSMutableAttributedString(string: "", attributes: nil) : NSMutableAttributedString(string: "\(stepsSection.name)\n", attributes: nil))
            for step in stepsSection.steps {
                result.append(NSMutableAttributedString(string: "\(step.number). \(step.step)\n", attributes: nil))
            }
        }
        attributes.removeAll()
        attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 17)
        result.addAttributes(attributes, range: NSRange(location: 0, length: result.length))
        return result
    }
}
