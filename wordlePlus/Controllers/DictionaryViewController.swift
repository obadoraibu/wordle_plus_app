//
//  DictionaryViewController.swift
//  wordlePlus
//
//  Created by Egor Zavyalov on 17.12.2023.
//

import UIKit
import CoreData

class DictionaryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    enum Constants {
        static let estimatedRowHeight: CGFloat = 44.0
        static let fontSize: CGFloat = 17.0
        static let cellReuseIdentifier = "Cell"
        static let blankString = ""
        static let NSSortDescriptorKey = "word"
    }

    var fetchedResultsController: NSFetchedResultsController<WordEntity>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.bgColor
        initializeFetchedResultsController()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath)
        let wordEntity = fetchedResultsController.object(at: indexPath)

        let wordText = wordEntity.word ?? Constants.blankString
        let definitionText = wordEntity.definition ?? Constants.blankString
        let boldAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: Constants.fontSize)]
        let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Constants.fontSize)]
        let attributedString = NSMutableAttributedString(string: wordText, attributes: boldAttribute)
        attributedString.append(NSAttributedString(string: " - \(definitionText)", attributes: regularAttribute))

        cell.textLabel?.attributedText = attributedString
        cell.textLabel?.textColor = ThemeManager.shared.newTextColor
        cell.textLabel?.numberOfLines = 0

        cell.contentView.backgroundColor = ThemeManager.shared.bgColor

        return cell
    }

    func initializeFetchedResultsController() {
        let request: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        let sort = NSSortDescriptor(key: Constants.NSSortDescriptorKey, ascending: true)
        request.sortDescriptors = [sort]

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    // swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            break
        }
    }
}
