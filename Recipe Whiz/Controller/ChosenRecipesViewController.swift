//
//  CurrentlyCookingViewController.swift
//  TinyChef
//
//  Created by David Hsieh on 1/4/22.
//

import Foundation
import UIKit

class ChosenRecipesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var dataController: DataController!
    
    var collectionViewIndexPath: IndexPath!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "image")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ThirdSegue" {
            let controller = segue.destination as! RecipeCardViewController
            controller.recipeCardInfo = ChosenRecipes.recipes[collectionViewIndexPath.row]
            controller.dataController = dataController
            controller.id = ChosenRecipes.recipes[collectionViewIndexPath.row].id
            controller.inChosenRecipes = true
            controller.chosenRecipesIndex = collectionViewIndexPath.row
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ChosenRecipes.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! CustomCollectionViewCell
        cell.imageView.image = ChosenRecipes.recipes[indexPath.row].image
        cell.activityIndicatorView.isHidden = true
        cell.statusTextView.isHidden = true
        cell.titleTextView.text = ChosenRecipes.recipes[indexPath.row].title
        cell.infoTextView.text = ChosenRecipes.recipes[indexPath.row].info.components(separatedBy: "serving")[0] + "serving"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewIndexPath = indexPath
        self.performSegue(withIdentifier: "ThirdSegue", sender: self)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 15
        let smallSide = min(view.frame.size.width, view.frame.size.height)
        let dimension = (smallSide - (2 * space))
        flowLayout.minimumInteritemSpacing = space
        flowLayout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        return CGSize(width: dimension, height: dimension)
    }
}
