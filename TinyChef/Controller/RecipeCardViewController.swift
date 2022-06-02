//
//  RecipeCardViewController.swift
//  TinyChef
//
//  Created by David Hsieh on 1/7/22.
//

import Foundation
import UIKit
import CoreData

class RecipeCardViewController: UIViewController {
    
    var dataController: DataController!
    
    var fetchedResultsController:NSFetchedResultsController<RecipeCardInfoEntity>!
    
    var recipeCardInfo: RecipeCardInfo!
    
    var recipeCardInfoEntity: RecipeCardInfoEntity!
    
    var id: Int!
    
    var inChosenRecipes: Bool!
    
    var chosenRecipesIndex: Int!
    
    var inSavedRecipes: Bool!
    
    // Below 4 properties are used for saving RecipeCardInfoEntity properties before deletion
    var image: Data!
    
    var titleString: String!
    
    var info: String!
    
    var instructions: String!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBOutlet weak var instructionsTextView: UITextView!
    
    @IBOutlet weak var chosenButton: UIBarButtonItem!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if inSavedRecipes {
            image = recipeCardInfoEntity.image
            titleString = recipeCardInfoEntity.title
            info = recipeCardInfoEntity.info
            instructions = recipeCardInfoEntity.instructions
            dataController.viewContext.delete(recipeCardInfoEntity)
            inSavedRecipes = false
        } else if recipeCardInfoEntity != nil {
            recipeCardInfoEntity = RecipeCardInfoEntity(entity: recipeCardInfoEntity.entity, insertInto: dataController.viewContext)
            recipeCardInfoEntity.id = Int64(id!)
            recipeCardInfoEntity.image = image
            recipeCardInfoEntity.title = titleString
            recipeCardInfoEntity.info = info
            recipeCardInfoEntity.instructions = instructions
            try? dataController.viewContext.save()
            inSavedRecipes = true
        } else {
            recipeCardInfoEntity = RecipeCardInfoEntity(context: dataController.viewContext)
            setRecipeCardInfoEntityAttributes()
            try? dataController.viewContext.save()
            inSavedRecipes = true
        }
    }
    
    @IBAction func chosenButtonTapped(_ sender: Any) {
        if inChosenRecipes {
            ChosenRecipes.recipes.remove(at: chosenRecipesIndex)
            updateChosenButton(inChosenRecipes: false)
            inChosenRecipes = false
        } else if recipeCardInfo != nil {
            ChosenRecipes.recipes.append(recipeCardInfo)
            chosenRecipesIndex = ChosenRecipes.recipes.count - 1
            updateChosenButton(inChosenRecipes: true)
            inChosenRecipes = true
        } else {
            recipeCardInfo = RecipeCardInfo(image: UIImage(data: recipeCardInfoEntity.image!)!, id: Int(recipeCardInfoEntity.id), title: recipeCardInfoEntity.title!, info: recipeCardInfoEntity.info!, instructions: recipeCardInfoEntity.instructions!, specialInstructions: nil)
            ChosenRecipes.recipes.append(recipeCardInfo)
            chosenRecipesIndex = ChosenRecipes.recipes.count - 1
            updateChosenButton(inChosenRecipes: true)
            inChosenRecipes = true
        }
    }
    
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
        setupFetchedResultsController()
        setInitialButtonStates()
        setUpView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recipeCardInfo = nil
        recipeCardInfoEntity = nil
        id = nil
        inChosenRecipes = nil
        chosenRecipesIndex = nil
        inSavedRecipes = nil
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func indexInChosenRecipes() -> Int? {
        for index in 0..<ChosenRecipes.recipes.count {
            if ChosenRecipes.recipes[index].id == id {
                return index
            }
        }
        return nil
    }
    
    fileprivate func objectInSavedRecipes() -> RecipeCardInfoEntity? {
        for index in 0..<fetchedResultsController.fetchedObjects!.count {
            if fetchedResultsController.object(at: IndexPath(row: index, section: 0)).id == id {
                return fetchedResultsController.object(at: IndexPath(row: index, section: 0))
            }
        }
        return nil
    }
    
    fileprivate func updateChosenButton(inChosenRecipes: Bool) {
        if inChosenRecipes {
            chosenButton.image = UIImage(systemName: "takeoutbag.and.cup.and.straw.fill")
        } else {
            chosenButton.image = UIImage(systemName: "takeoutbag.and.cup.and.straw")
        }
    }
    
    fileprivate func updateSaveButton(inSavedRecipes: Bool) {
        if inSavedRecipes {
            saveButton.image = UIImage(systemName: "bookmark.fill")
        } else {
            saveButton.image = UIImage(systemName: "bookmark")
        }
    }
    
    fileprivate func setInitialButtonStates() {
        if inChosenRecipes == nil {
            chosenRecipesIndex = indexInChosenRecipes()
            if chosenRecipesIndex == nil {
                updateChosenButton(inChosenRecipes: false)
                inChosenRecipes = false
            } else {
                recipeCardInfo = ChosenRecipes.recipes[chosenRecipesIndex]
                updateChosenButton(inChosenRecipes: true)
                inChosenRecipes = true
            }
        } else {
            updateChosenButton(inChosenRecipes: true)
        }
        
        if inSavedRecipes == nil {
            recipeCardInfoEntity = objectInSavedRecipes()
            if recipeCardInfoEntity == nil {
                updateSaveButton(inSavedRecipes: false)
                inSavedRecipes = false
            } else {
                updateSaveButton(inSavedRecipes: true)
                inSavedRecipes = true
            }
        } else {
            updateSaveButton(inSavedRecipes: true)
        }
    }
    
    fileprivate func setUpView() {
        if recipeCardInfo != nil {
            imageView.image = recipeCardInfo.image
            titleLabel.text = recipeCardInfo.title
            infoTextView.text = recipeCardInfo.info
            if recipeCardInfo.specialInstructions != nil {
                instructionsTextView.attributedText = recipeCardInfo.specialInstructions
            } else {
                instructionsTextView.text = recipeCardInfo.instructions
            }
        } else {
            imageView.image = UIImage(data: recipeCardInfoEntity.image!)
            titleLabel.text = recipeCardInfoEntity.title
            infoTextView.text = recipeCardInfoEntity.info
            instructionsTextView.text = recipeCardInfoEntity.instructions
        }
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
    }
    
    fileprivate func setRecipeCardInfoEntityAttributes() {
        recipeCardInfoEntity.title = recipeCardInfo.title
        recipeCardInfoEntity.instructions = recipeCardInfo.instructions
        recipeCardInfoEntity.info = recipeCardInfo.info
        recipeCardInfoEntity.image = recipeCardInfo.image.pngData()
        recipeCardInfoEntity.id = Int64(recipeCardInfo.id)
    }
}

extension RecipeCardViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            updateSaveButton(inSavedRecipes: false)
            break
        case .insert:
            updateSaveButton(inSavedRecipes: true)
        default:
            break
        }
    }
}
