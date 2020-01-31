//
//  Spell+Convenience.swift
//  HarryPotter-CoreData-xcode
//
//  Created by Austin Potts on 1/29/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum ThreatLevel: String, CaseIterable {
    case 🤢
    case 🤕
    case 💀
}


extension Spell {
    
    var spellRepresentation: SpellRepresentation? {
        guard let name = name,
        let details = details,
        let threatLevel = threatLevel,
            let identifier = identifier else { return nil }
        
        return SpellRepresentation(name: name, details: details, threatLevel: threatLevel, identifier: identifier)
    }
    
    @discardableResult convenience init(name: String, details: String, threatLevel: ThreatLevel, identifier: UUID = UUID(), context: NSManagedObjectContext) {
        
        self.init(context: context)
        self.name = name
        self.details = details
        self.threatLevel = threatLevel.rawValue
        
    }
    
    @discardableResult convenience init?(spellRepresentation: SpellRepresentation, context: NSManagedObjectContext) {
        guard let threatLevel = ThreatLevel(rawValue: spellRepresentation.threatLevel) else { return nil }
        
        self.init(name: spellRepresentation.name,
                  details: spellRepresentation.details,
                  threatLevel: threatLevel,
                  identifier: spellRepresentation.identifier,
                  context: context)
    }
    
}
