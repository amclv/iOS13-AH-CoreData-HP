//
//  SpellListTableViewController.swift
//  HarryPotter-CoreData-xcode
//
//  Created by Austin Potts on 1/29/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class SpellListTableViewController: UITableViewController {
    
    var spellController = SpellController()


    lazy var fetchResultsController: NSFetchedResultsController<Spell> = {
        
        //Create fetch request
        let fetchRequest:NSFetchRequest<Spell> = Spell.fetchRequest()
        
        //Sort the fetched results
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "threatLevel", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.share.mainContext, sectionNameKeyPath: "threatLevel", cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch: \(error)")
        }
        
        return frc
        
    }()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        spellController.fetchSpellFromServer()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpellCell", for: indexPath)

        // Configure the cell...
        let spell = fetchResultsController.object(at: indexPath)
        cell.textLabel?.text = spell.name
//        cell.textLabel?.textColor = .white

        return cell
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sectionInfo = fetchResultsController.sections?[section] else {return nil}
        
        return sectionInfo.name.capitalized
        
        
    }

  
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let spell = fetchResultsController.object(at: indexPath)
        spellController.deleteSpell(spell: spell)
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "ShowSpellSegue" {
            if let detailVC = segue.destination as? SpellDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                
                let spell = fetchResultsController.object(at: indexPath)
                detailVC.spell = spell
                detailVC.spellController = spellController
                
                //MARK: - Day 2
                //detailVC.spellController = spellController
                
            }
        } else if segue.identifier == "AddSpellSegue" {
            if let detailVC = segue.destination as? SpellDetailViewController {
                detailVC.spellController = spellController
            }
        }
        
    }
    

}


extension SpellListTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else{return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else{return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else{return}
            tableView.moveRow(at: indexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else{return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
        @unknown default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let sectionSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(sectionSet, with: .automatic)
            
        case .delete:
            tableView.deleteSections(sectionSet, with: .automatic)
            
        default: return
        }
        
    }
    
}
