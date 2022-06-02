//
//  SceneDelegate.swift
//  TinyChef
//
//  Created by David Hsieh on 1/3/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: "TinyChef")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        dataController.load()
        
        let tabBarController = window?.rootViewController as! UITabBarController
        
        let viewControllers = tabBarController.viewControllers!
        let searchRecipeVC = (viewControllers[0] as! UINavigationController).topViewController as! SearchRecipeViewController
        let searchByIngredientsVC = (viewControllers[1] as! UINavigationController).topViewController as! SearchByIngredientsViewController
        let chosenRecipesVC = (viewControllers[2] as! UINavigationController).topViewController as! ChosenRecipesViewController
        let favoriteRecipesVC = (viewControllers[3] as! UINavigationController).topViewController as! FavoriteRecipesViewController
        searchRecipeVC.dataController = dataController
        searchByIngredientsVC.dataController = dataController
        chosenRecipesVC.dataController = dataController
        favoriteRecipesVC.dataController = dataController
    }
}

