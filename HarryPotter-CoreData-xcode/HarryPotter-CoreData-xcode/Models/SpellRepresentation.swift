//
//  SpellRepresentation.swift
//  HarryPotter-CoreData-xcode
//
//  Created by Aaron Cleveland on 1/30/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct SpellRepresentation: Codable {
    let name: String
    let details: String
    let threatLevel: String
    let identifier: UUID
}
