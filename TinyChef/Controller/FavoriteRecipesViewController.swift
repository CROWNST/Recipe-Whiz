//
//  FavoriteRecipesViewController.swift
//  TinyChef
//
//  Created by David Hsieh on 1/4/22.
//

import Foundation
import UIKit
import CoreData

class FavoriteRecipesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var dataController: DataController!
    
    var collectionViewIndexPath: IndexPath!
    
    var fetchedResultsController: NSFetchedResultsController<RecipeCardInfoEntity>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<RecipeCardInfoEntity> = RecipeCardInfoEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "recipes")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? fetchedResultsController.performFetch()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "image")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FourthSegue" {
            let controller = segue.destination as! RecipeCardViewController
            controller.recipeCardInfoEntity = fetchedResultsController.object(at: collectionViewIndexPath)
            controller.dataController = dataController
            controller.id = Int(fetchedResultsController.object(at: collectionViewIndexPath).id)
            controller.inSavedRecipes = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! CustomCollectionViewCell
        cell.imageView.image = UIImage(data: fetchedResultsController.object(at: indexPath).image!)
        cell.activityIndicatorView.isHidden = true
        cell.statusTextView.isHidden = true
        cell.titleTextView.text = fetchedResultsController.object(at: indexPath).title
        cell.infoTextView.text = fetchedResultsController.object(at: indexPath).info!.components(separatedBy: "serving")[0] + "serving"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewIndexPath = indexPath
        self.performSegue(withIdentifier: "FourthSegue", sender: self)
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
