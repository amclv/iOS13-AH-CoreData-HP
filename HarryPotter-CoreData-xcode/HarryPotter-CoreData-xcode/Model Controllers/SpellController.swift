//
//  SpellController.swift
//  HarryPotter-CoreData-xcode
//
//  Created by Aaron Cleveland on 1/30/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

class SpellController {
    
    // establish the base url
    let baseURL = URL(string: "https://spelldata-b708a.firebaseio.com/")!
    
    // fetch from server
    func fetchSpellFromServer(completion: @escaping () -> Void = {} ) {
        
        // setup url
        let requestURL = baseURL.appendingPathExtension("json")
        
        // setup request url
        let request = URLRequest(url: requestURL)
        
        // perform data task
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            //Error handle
            if let error = error {
                NSLog("Error occured with request: \(error)")
                completion()
                return
            }
            
            guard let data = data else {
                NSLog("Error occured with collecting data: \(error)")
                completion()
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let spell = try decoder.decode([String: SpellRepresentation].self, from: data).map({$0.value})
                //call the update
                
            } catch {
                NSLog("Error decoding: \(error)")
            }
            completion()
        }.resume()
    }
    
    // update on server
    func updateSpell(with representations: [SpellRepresentation]) {
        let identifiersToFetch = representations.map({$0.identifier})
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var spellToCreate = representationByID
        
        // adding background context
        let context = CoreDataStack.share.container.newBackgroundContext()
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<Spell> = Spell.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                let existingSpell = try context.fetch(fetchRequest)
                for spell in existingSpell {
                    guard let identifier = spell.identifier,
                        let representation = representationByID[identifier] else { continue }
                    spell.name = representation.name
                    spell.details = representation.details
                    spell.threatLevel = representation.threatLevel
                    spellToCreate.removeValue(forKey: identifier)
                }
                
                for representation in spellToCreate.values {
                    Spell(spellRepresentation: representation, context: context)
                }
                
                CoreDataStack.share.save(context: context)
            } catch {
                NSLog("Error fetching Spell: \(error)")
            }
        }
    }
    
    func putSpell(spell: Spell, completion: @escaping() -> Void = {} ) {
        // find a unique place to put this spell
        let identifier = spell.identifier ?? UUID()
        spell.identifier = identifier
        
        // request url
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString)
                                .appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        guard let spellRepresentation = spell.spellRepresentation else {
            NSLog("Error with request URL")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(spellRepresentation)
        } catch {
            NSLog("Error encoding: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error with data task: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
        
    func deleteFromServer(_ spell: Spell, completion: @escaping() -> Void = {}) {
        guard let identifier = spell.identifier else {
            completion()
            return
        }
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString)
                                .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error deleting: \(error)")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    // crud methods
    func createSpell(with name: String, details: String, threatLevel: ThreatLevel, context: NSManagedObjectContext) {
    
        let spell = Spell(name: name, details: details, threatLevel: threatLevel, context: context)
        CoreDataStack.share.save()
        putSpell(spell: spell)
    }
    
    func updateSpell(spell: Spell, name: String, details: String, threatLevel: ThreatLevel) {
        spell.name = name
        spell.details = details
        spell.threatLevel = threatLevel.rawValue
        
        CoreDataStack.share.save()
        putSpell(spell: spell)
    }
    
    func deleteSpell(spell: Spell) {
        deleteFromServer(spell)
        CoreDataStack.share.mainContext.delete(spell)
        CoreDataStack.share.save()
    }
}
