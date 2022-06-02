//
//  SearchByIngredientsViewController.swift
//  TinyChef
//
//  Created by David Hsieh on 1/4/22.
//

import Foundation
import UIKit

class SearchByIngredientsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    
    @IBOutlet weak var searchRecipesButton: UIButton!
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var ingredients = [String]()
    
    var autocompleteIngredients = [AutocompleteIngredient]()
    
    var currentSearchTask: URLSessionDataTask?
    
    var dataController: DataController!
    
    var collectionViewIndexPath: IndexPath!
    
    @IBAction func searchRecipesButtonTapped(_ sender: Any) {
        updateUI(hiding: true)
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        let ingredientsString = ingredients.map({$0}).joined(separator: ", ")
        _ = SpoonacularClient.searchRecipeComplex(query: nil, includeIngredients: ingredientsString, ranking: 0, completion: handleSearchRecipeComplexResponse(recipes:error:))
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        updateUI(hiding: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.isHidden = true
        navigationItem.rightBarButtonItems?.append(editButtonItem)
        updateUI(hiding: true)
        
        searchBar.returnKeyType = .default
        searchBar.delegate = self
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "image")
    }
    
    fileprivate func handleSearchRecipeComplexResponse(recipes: [SearchRecipeComplex], error: Error?) {
        if error == nil {
            RecipeComplexModelIngredients.recipes = recipes
            RecipeComplexModelIngredients.images = Array(repeating: nil, count: RecipeComplexModelIngredients.recipes.count)
            RecipeComplexModelIngredients.imageDataTasks = Array(repeating: nil, count: RecipeComplexModelIngredients.recipes.count)
            for position in 0..<RecipeComplexModelIngredients.recipes.count {
                if let imagePath = RecipeComplexModelIngredients.recipes[position].image {
                    let dataTask = SpoonacularClient.downloadImage(path: imagePath, position: position, completion: handleDownloadImageResponse(data:error:position:))
                    RecipeComplexModelIngredients.imageDataTasks[position] = dataTask
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
            RecipeComplexModelIngredients.images[position] = UIImage(data: data!)
        } else {
            let plateSymbol = UIImage(named: "PlateSymbol")
            RecipeComplexModelIngredients.images[position] = plateSymbol!
        }
        collectionView.reloadData()
    }
    
    func handleAutocompleteResponse(ingredients: [AutocompleteIngredient], error: Error!) {
        if error == nil {
            autocompleteIngredients = ingredients
            tableView.reloadData()
            if autocompleteIngredients.isEmpty {
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
    
    // Does not reload table view data
    fileprivate func updateUI(hiding: Bool) {
        if hiding {
            if isEditing {
                navigationItem.rightBarButtonItems?[1].sendAction()
            }
            if navigationItem.rightBarButtonItems?.count == 2 {
                navigationItem.rightBarButtonItem = nil
            }
            searchBar.endEditing(true)
        } else {
            if navigationItem.rightBarButtonItems!.count == 1 {
                navigationItem.rightBarButtonItems?.insert(cancelButton, at: 0)
            }
        }
        if !isEditing {
            updateEditButtonState()
        }
        searchRecipesButton.isHidden = hiding
        ingredientsTableView.isHidden = hiding
        navigationItem.title = hiding ? "By Ingredients" : "Ingredients"
    }
    
    fileprivate func updateEditButtonState() {
        if ingredients.isEmpty {
            if navigationItem.rightBarButtonItems?.count == 1 {
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                navigationItem.rightBarButtonItems?[1].isEnabled = false
            }
        } else {
            if navigationItem.rightBarButtonItems?.count == 1 {
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                navigationItem.rightBarButtonItems?[1].isEnabled = true
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        ingredientsTableView.setEditing(editing, animated: animated)
        updateEditButtonState()
        if navigationItem.rightBarButtonItems?.count == 1 {
            updateUI(hiding: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SecondSegue" {
            let controller = segue.destination as! RecipeCardViewController
            let image: UIImage
            if RecipeComplexModelIngredients.images[collectionViewIndexPath.row] == nil {
                image = UIImage(named: "PlateSymbol")!
            } else {
                image = RecipeComplexModelIngredients.images[collectionViewIndexPath.row]!
            }
            let searchRecipeComplexModel = RecipeComplexModelIngredients.recipes[collectionViewIndexPath.row]
            let info = RecipeCardInfo.info(readyInMinutes: searchRecipeComplexModel.readyInMinutes, servings: searchRecipeComplexModel.servings, vegetarian: searchRecipeComplexModel.vegetarian, vegan: searchRecipeComplexModel.vegan, glutenFree: searchRecipeComplexModel.glutenFree, dairyFree: searchRecipeComplexModel.dairyFree)
            var ingredients = searchRecipeComplexModel.missedIngredients!
            ingredients.append(contentsOf: searchRecipeComplexModel.usedIngredients!)
            let instructions = RecipeCardInfo.instructions(ingredients: ingredients, analyzedInstructions: searchRecipeComplexModel.analyzedInstructions)
            let specialInstructions = RecipeCardInfo.specialInstructions(missedIngredientCount: searchRecipeComplexModel.missedIngredientCount!, missedIngredients: searchRecipeComplexModel.missedIngredients!, usedIngredients: searchRecipeComplexModel.usedIngredients!, analyzedInstructions: searchRecipeComplexModel.analyzedInstructions)
            let recipeCardInfo = RecipeCardInfo(image: image, id: searchRecipeComplexModel.id, title: searchRecipeComplexModel.title, info: info, instructions: instructions, specialInstructions: specialInstructions)
            controller.recipeCardInfo = recipeCardInfo
            controller.dataController = dataController
            controller.id = searchRecipeComplexModel.id
        }
    }
}

extension SearchByIngredientsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
        currentSearchTask = SpoonacularClient.autocompleteIngredient(query: searchText, number: 25, completion: handleAutocompleteResponse(ingredients:error:))
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        updateUI(hiding: false)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        tableView.isHidden = true
        currentSearchTask?.cancel()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateUI(hiding: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !(searchBar.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ingredients.append(searchBar.text!)
            ingredientsTableView.reloadData()
            updateUI(hiding: false)
        }
    }
}

extension SearchByIngredientsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return ingredients.count
        default:
            return autocompleteIngredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        switch tableView.tag {
        case 0:
            let ingredient = ingredients[indexPath.row]
            cell.textLabel?.text = "\(ingredient)"
            return cell
        default:
            let ingredient = autocompleteIngredients[indexPath.row]
            cell.textLabel?.text = "\(ingredient.name)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            let ingredient = autocompleteIngredients[indexPath.row].name
            ingredients.append(ingredient)
            ingredientsTableView.reloadData()
            updateUI(hiding: false)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            ingredients.remove(at: indexPath.row)
            ingredientsTableView.reloadData()
        default: () // Unsupported
        }
    }
}

extension SearchByIngredientsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RecipeComplexModelIngredients.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! CustomCollectionViewCell
        if (RecipeComplexModelIngredients.images[indexPath.row] != nil) {
            let missed = RecipeComplexModelIngredients.recipes[indexPath.row].missedIngredientCount ?? 0
            if missed > 0 {
                cell.statusTextView.isHidden = false
                cell.statusTextView.text = "\(missed)!"
            }
            let image = RecipeComplexModelIngredients.images[indexPath.row]!
            cell.imageView.image = image
            cell.activityIndicatorView.isHidden = true
        } else {
            if RecipeComplexModelIngredients.imageDataTasks[indexPath.row] != nil {
                cell.activityIndicatorView.startAnimating()
            } else {
                cell.activityIndicatorView.isHidden = true
            }
            cell.imageView.image = UIImage(named: "PlateSymbol")
            cell.statusTextView.isHidden = true
        }
        cell.titleTextView.text = RecipeComplexModelIngredients.recipes[indexPath.row].title
        cell.infoTextView.text = "⏱ \(RecipeComplexModelIngredients.recipes[indexPath.row].readyInMinutes) min 🍽 \(RecipeComplexModelIngredients.recipes[indexPath.row].servings) serving"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewIndexPath = indexPath
        self.performSegue(withIdentifier: "SecondSegue", sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 15
        let smallSide = collectionView.frame.size.width
        let dimension = (smallSide - (3 * space)) / 2.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        return CGSize(width: dimension, height: dimension)
    }
}
