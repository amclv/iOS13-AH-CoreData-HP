//
//  SpellDetailViewController.swift
//  HarryPotter-CoreData-xcode
//
//  Created by Austin Potts on 1/29/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SpellDetailViewController: UIViewController {

    @IBOutlet weak var spellName: UITextField!
    @IBOutlet weak var threatLevelSegmentController: UISegmentedControl!
    
    @IBOutlet weak var spellDetails: UITextView!
    @IBOutlet weak var saveSpell: UIButton!
    
    
    
    var spell: Spell?
    var spellController: SpellController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveSpell.layer.cornerRadius = 25

        // Do any additional setup after loading the view.
        updateViews()
    }
    

    @IBAction func spellButtonTapped(_ sender: Any) {
        if let name = spellName.text,
            let details = spellDetails.text {
            let index = threatLevelSegmentController.selectedSegmentIndex
            let threatLevel = ThreatLevel.allCases[index]
            if let spell = spell {
                spellController?.updateSpell(spell: spell, name: name, details: details, threatLevel: threatLevel)
            } else {
                spellController?.createSpell(with: name, details: details, threatLevel: threatLevel, context: CoreDataStack.share.mainContext)
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func updateViews() {
        guard isViewLoaded else { return }
        title = spell?.name ?? ""
        spellDetails.text = spell?.details
        spellName.text = spell?.name
        
        if let threatString = spell?.threatLevel,
            let threatLevel = ThreatLevel(rawValue: threatString) {
            let index = ThreatLevel.allCases.firstIndex(of: threatLevel) ?? 0
            threatLevelSegmentController.selectedSegmentIndex = index
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
