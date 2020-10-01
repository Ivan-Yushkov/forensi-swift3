//
//  MultipleEntryViewControllerTableViewDataSource.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 31/01/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension MultipleEntryViewController: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ef = self._entryField {
            return ef.fields.count
        }
        return 0
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let ef = self._entryField {
            let field = ef.fields[indexPath.row]
            
            var c: MultipleEntryViewCell? = .none
            
            if let cDeque = tableView.dequeueReusableCell(withIdentifier: _textCellIdentifier) as? MultipleEntryViewCell {
                c = cDeque
            } else {
                c = getOwnCell()
            }
            
            if let cell = c {
                if let f = MiscHelpers.CastEntryFormField(field, String.self) {
                    HandleCell(cell, entryFormBaseFieldType: f, cellNumber: indexPath.row + 1)
                } else if let f = MiscHelpers.CastEntryFormField(field, Int.self) {
                    HandleCell(cell, entryFormBaseFieldType: f, cellNumber: indexPath.row + 1)
                } else if let f = MiscHelpers.CastEntryFormField(field, Float.self) {
                    HandleCell(cell, entryFormBaseFieldType: f, cellNumber: indexPath.row + 1)
                } else if let f = MiscHelpers.CastEntryFormField(field, Double.self) {
                    HandleCell(cell, entryFormBaseFieldType: f, cellNumber: indexPath.row + 1)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func HandleCell<T>(_ cell: MultipleEntryViewCell, entryFormBaseFieldType: EntryFormBaseFieldType<T>, cellNumber: Int){
        cell.descriptionLabel.text = entryFormBaseFieldType.displaySelectedValue()
        cell.cellNumer.text = "\(cellNumber)"
        if entryFormBaseFieldType.attachments.count > 0 {
            cell.accessoryType = .disclosureIndicator
        }
    }
//MARK: fix2020
    fileprivate func getOwnCell() -> MultipleEntryViewCell? {
       // if let bundle: Bundle = Bundle.main {
            if let objects = Bundle.main.loadNibNamed("MultipleEntryViewCell", owner: self, options: nil) {
           // let objects = bundle.loadNibNamed("MultipleEntryViewCell", owner: self, options: nil)
           // if objects.count > 0 {
                if let c = objects.first as? MultipleEntryViewCell {
                    return c
                }
            //}
        }
        return nil
    }
}
