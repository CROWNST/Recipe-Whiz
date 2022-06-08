//
//  ViewController.swift
//  TinyChef
//
//  Created by David Hsieh on 1/3/22.
//

import Foundation
import UIKit

class SearchRecipeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var tableView: UITableView!
    
    var autocompleteRecipes = [AutocompleteRecipe]()
    
    var currentSearchTask: URLSessionDataTask?
    
    var dataController: DataController!
    
    var collectionViewIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        activityIndicatorView.isHidden = true
        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "image")
    }
    
    fileprivate func handleSearchRecipeComplexResponse(recipes: [SearchRecipeComplex], error: Error?) {
        if error == nil {
            RecipeComplexModel.recipes = recipes
            RecipeComplexModel.images = Array(repeating: nil, count: RecipeComplexModel.recipes.count)
            RecipeComplexModel.imageDataTasks = Array(repeating: nil, count: RecipeComplexModel.recipes.count)
            for position in 0..<RecipeComplexModel.recipes.count {
                if let imagePath = RecipeComplexModel.recipes[position].image {
                    let dataTask = SpoonacularClient.downloadImage(path: imagePath, position: position, completion: handleDownloadImageResponse(data:error:position:))
                    RecipeComplexModel.imageDataTasks[position] = dataTask
                }
            }
            activityIndicatorView.isHidden = true
            collectionView.reloadData()
        } else {
            activityIndicatorView.isHidden = true
            presentAlertController(error: error)
        }
    }
    
    fileprivate func handleDownloadImageResponse(data: Data?, error: Error?, position: Int) {
        if data != nil {
            RecipeComplexModel.images[position] = UIImage(data: data!)
        } else {
            let plateSymbol = UIImage(named: "PlateSymbol")
            RecipeComplexModel.images[position] = plateSymbol!
        }
        collectionView.reloadData()
    }
    
    func handleAutocompleteResponse(recipes: [AutocompleteRecipe], error: Error!) {
        if error == nil {
            autocompleteRecipes = recipes
            tableView.reloadData()
            if autocompleteRecipes.isEmpty {
                tableView.isHidden = true
            } else {
                tableView.isHidden = false
            }
        }
    }
    
    fileprivate func presentAlertController(error: Error?) {
        let controller = UIAlertController()
        controller.title = "No Recipes"
        controller.message = error?.localizedDescription
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { action in self.dismiss(animated: true, completion: nil)
        }

        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FirstSegue" {
            let controller = segue.destination as! RecipeCardViewController
            let image: UIImage
            if RecipeComplexModel.images[collectionViewIndexPath.row] == nil {
                image = UIImage(named: "PlateSymbol")!
            } else {
                image = RecipeComplexModel.images[collectionViewIndexPath.row]!
            }
            let searchRecipeComplexModel = RecipeComplexModel.recipes[collectionViewIndexPath.row]
            let info = RecipeCardInfo.info(readyInMinutes: searchRecipeComplexModel.readyInMinutes, servings: searchRecipeComplexModel.servings, vegetarian: searchRecipeComplexModel.vegetarian, vegan: searchRecipeComplexModel.vegan, glutenFree: searchRecipeComplexModel.glutenFree, dairyFree: searchRecipeComplexModel.dairyFree)
            let instructions = RecipeCardInfo.instructions(ingredients: searchRecipeComplexModel.missedIngredients!, analyzedInstructions: searchRecipeComplexModel.analyzedInstructions)
            let recipeCardInfo = RecipeCardInfo(image: image, id: searchRecipeComplexModel.id, title: searchRecipeComplexModel.title, info: info, instructions: instructions, specialInstructions: nil)
            controller.recipeCardInfo = recipeCardInfo
            controller.dataController = dataController
            controller.id = searchRecipeComplexModel.id
        }
    }
}

extension SearchRecipeViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
        currentSearchTask = SpoonacularClient.autocompleteRecipe(query: searchText, number: 25, completion: handleAutocompleteResponse(recipes:error:))
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        currentSearchTask?.cancel()
        currentSearchTask = SpoonacularClient.autocompleteRecipe(query: searchBar.text!, number: 25, completion: handleAutocompleteResponse(recipes:error:))
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        tableView.isHidden = true
        currentSearchTask?.cancel()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        _ = SpoonacularClient.searchRecipeComplex(query: searchBar.text, includeIngredients: nil, ranking: 2, completion: handleSearchRecipeComplexResponse(recipes:error:))
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
}

extension SearchRecipeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutocompleteRecipeCell")!
        let recipe = autocompleteRecipes[indexPath.row]
        cell.textLabel?.text = "\(recipe.title)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        searchBar.text = autocompleteRecipes[indexPath.row].title
        _ = SpoonacularClient.searchRecipeComplex(query: searchBar.text, includeIngredients: nil, ranking: 2, completion: handleSearchRecipeComplexResponse(recipes:error:))
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchRecipeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RecipeComplexModel.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! CustomCollectionViewCell
        if (RecipeComplexModel.images[indexPath.row] != nil) {
            let image = RecipeComplexModel.images[indexPath.row]!
            cell.imageView.image = image
            cell.activityIndicatorView.isHidden = true
        } else {
            if RecipeComplexModel.imageDataTasks[indexPath.row] != nil {
                cell.activityIndicatorView.startAnimating()
            } else {
                cell.activityIndicatorView.isHidden = true
            }
            cell.imageView.image = UIImage(named: "PlateSymbol")
        }
        cell.statusTextView.isHidden = true
        cell.titleTextView.text = RecipeComplexModel.recipes[indexPath.row].title
        cell.infoTextView.text = "⏱ \(RecipeComplexModel.recipes[indexPath.row].readyInMinutes) min 🍽 \(RecipeComplexModel.recipes[indexPath.row].servings) serving"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewIndexPath = indexPath
        self.performSegue(withIdentifier: "FirstSegue", sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 15
        let smallSide = min(view.frame.size.width, view.frame.size.height)
        let dimension = (smallSide - (3 * space)) / 2.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        return CGSize(width: dimension, height: dimension)
    }
}

