//
//  EntryFormMultipleChoiceFactory.swift
//  BitmelterEntryForm

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


public protocol EntryFormMultipleChoiceDelegate {
    func enterValueForOther<T>(_ f: EntryFormBaseFieldType<T>)
    func valueHasBeenSelected()
}

//This factory works only with checkbox and radio types
open class EntryFormMultipleChoiceFactory: NSObject, UITableViewDataSource, UITableViewDelegate, CommentsFieldHasChangedDelegate {
    fileprivate var _entryForm: EntryForm
    fileprivate var _entryField: Any
    fileprivate let _displayLabelCellIdentifier: String
    fileprivate var _displayLabel: String
    fileprivate let _textCellIdentifier: String
    fileprivate let _imageCellIdentifier: String
    fileprivate let _commentsCellIdentifier: String
    fileprivate var _tableView: UITableView?
    fileprivate var _delegate: EntryFormMultipleChoiceDelegate?
    fileprivate var _sectionPleaseSelectOrTitle = -1
    fileprivate var _sectionImages = -1
    fileprivate var _sectionComments = -1
    fileprivate var _sectionSelector = -1
    fileprivate var _cellsState = [Int:Bool]()
    fileprivate var _isRadioType = false
    
    //if no selected ( cell 1 true) - show comments
    fileprivate var displayComments = false {
        didSet {
            print(displayComments)
            shouldRefresh()
        }
    }
    
    //check ID and orientatedEntryField
    fileprivate var entryFieldID: String = ""
    fileprivate var orientatedEntryField = false
    //change this value only once we click the box
    fileprivate var didChangeSelection = false
        
    
    public init(tableView: UITableView, entryForm: EntryForm, entryField: Any, delegate: EntryFormMultipleChoiceDelegate) {
        _entryForm = entryForm
        _entryField = entryField
        _textCellIdentifier = MiscHelpers.RandomStringWithLength(10)
        _imageCellIdentifier = MiscHelpers.RandomStringWithLength(10)
        _commentsCellIdentifier = MiscHelpers.RandomStringWithLength(10)
        _displayLabelCellIdentifier = MiscHelpers.RandomStringWithLength(10)
        _tableView = tableView
        _delegate = delegate
        
        if let f = MiscHelpers.CastEntryFormField(entryField, Int.self) {
            _displayLabel = f.displayLabel
        } else if let f = MiscHelpers.CastEntryFormField(entryField, Float.self) {
            _displayLabel = f.displayLabel
        } else if let f = MiscHelpers.CastEntryFormField(entryField, Double.self) {
            _displayLabel = f.displayLabel
        } else if let f = MiscHelpers.CastEntryFormField(entryField, String.self) {
            _displayLabel = f.displayLabel
            entryFieldID = f.id
        } else {
            _displayLabel = ""
        }
        
        super.init()
        
        if let f = MiscHelpers.CastEntryFormField(entryField, Int.self) {
            initCellStatesDictionary(f)
        } else if let f = MiscHelpers.CastEntryFormField(entryField, Float.self) {
            initCellStatesDictionary(f)
        } else if let f = MiscHelpers.CastEntryFormField(entryField, Double.self) {
            initCellStatesDictionary(f)
        } else if let f = MiscHelpers.CastEntryFormField(entryField, String.self) {
            initCellStatesDictionary(f)
        }
        
        checkCellStates()
        
        let bundle = Bundle.main
        let nibRadioCheckBox = UINib(nibName: "RadioCheckboxViewCell", bundle: bundle)
        tableView.register(nibRadioCheckBox, forCellReuseIdentifier: _textCellIdentifier)
        
        let nibImageEntry = UINib(nibName: "ImageEntryFormCell", bundle: bundle)
        tableView.register(nibImageEntry, forCellReuseIdentifier: _imageCellIdentifier)
        
        let nibComments = UINib(nibName: "CommentsViewCell", bundle: bundle)
        tableView.register(nibComments, forCellReuseIdentifier: _commentsCellIdentifier)
        
        //TODO: add new cell with picker for lang
//        let nibPicker = UINib(nibName: "PickerViewCell", bundle: bundle)
//        tableView.register(nibComments, forCellReuseIdentifier: _commentsCellIdentifier)
        
        let nibDisplayLabel = UINib(nibName: "DisplayLabelViewCell", bundle: bundle)
        tableView.register(nibDisplayLabel, forCellReuseIdentifier: _displayLabelCellIdentifier)
        
    }//end Init
    
    fileprivate func initCellStatesDictionary<T>(_ f: EntryFormBaseFieldType<T>) {
        self._isRadioType = MiscHelpers.IsRadio(f)
        for (idx,value) in f.values.enumerated() {
            _cellsState[idx] = f.isValueSelected(value)
            
        }
    }
    
    fileprivate func checkCellStates() {
        if let first = _cellsState[0], let second = _cellsState[1], second {
            displayComments = true
        } else {
            displayComments = false
        }
    }
    
    fileprivate func getOwnCell() -> RadioCheckboxViewCell? {
        return _getOwnCell("RadioCheckboxViewCell", type: RadioCheckboxViewCell.self)
    }
    
    fileprivate func getOwnImageCell() -> ImageEntryFormCell? {
        return _getOwnCell("ImageEntryFormCell", type: ImageEntryFormCell.self)
    }
    
    fileprivate func getCommentsCell() -> CommentsViewCell? {
        return _getOwnCell("CommentsViewCell", type: CommentsViewCell.self)
    }
    //TODO: add picker cell
    
    fileprivate func getDisplayLabelCell() -> DisplayLabelViewCell? {
        return _getOwnCell("DisplayLabelViewCell", type: DisplayLabelViewCell.self)
    }
    
    fileprivate func _getOwnCell<T>(_ name: String, type: T.Type) -> T? {
        let bundle = Bundle.main
        let objects = bundle.loadNibNamed(name, owner: self, options: nil)
        if objects?.count > 0 {
            if let c = objects![0] as? T {
                return c
            }
        }
        return .none
    }
    
    fileprivate var _lastIndex: IndexPath? = .none
    fileprivate var lastIndex: IndexPath? {
        get{
            let ret: IndexPath? = _lastIndex
            return ret
        }
        set{
            _lastIndex = newValue
        }
    }
    
    open func shouldRefresh(){
        if let tbl = _tableView {
            tbl.reloadData()
        }
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        var ret = 1
        _sectionPleaseSelectOrTitle = 0
        if let f = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
            if f.attachmentsSpec.AllowsAttachments {
                _sectionImages = 1
                ret = 2
            }
            if let _ = f.fieldComments {
                _sectionComments = _sectionImages > -1 ? _sectionImages + 1 : 1
                ret = ret + 1
            }
        } else if let f = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
            if f.attachmentsSpec.AllowsAttachments {
                _sectionImages = 1
                ret = 2
            }
            if let _ = f.fieldComments {
                _sectionComments = _sectionImages > -1 ? _sectionImages + 1 : 1
                ret = ret + 1
            }
        } else if let f = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
            if f.attachmentsSpec.AllowsAttachments {
                _sectionImages = 1
                ret = 2
            }
            if let _ = f.fieldComments {
                _sectionComments = _sectionImages > -1 ? _sectionImages + 1 : 1
                ret = ret + 1
            }
        } else if let f = MiscHelpers.CastEntryFormField(_entryField, String.self) {
            if f.attachmentsSpec.AllowsAttachments {
                _sectionImages = 1
                ret = 2
            }
            
            //if  radio b with comment textfield
            //_sectionComments gets 1 or sectionImages + 1
            // return 2 sections or more in case of images
            
            if let _ = f.fieldComments  {
                if entryFieldID.contains("orientated") {
                    orientatedEntryField = true
                    if displayComments {
                    _sectionComments = _sectionImages > -1 ? _sectionImages + 1 : 1
                    ret = ret + 1
                    }
                } else {
                    orientatedEntryField = false
                    _sectionComments = _sectionImages > -1 ? _sectionImages + 1 : 1
                    ret = ret + 1
                }
            }
        }
        return ret
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == _sectionPleaseSelectOrTitle {
            return NSLocalizedString("Please select", comment: "Title of please select section in multiple choice table (checkbox or radio)")
        } else if section == _sectionImages {
            return NSLocalizedString("Images", comment: "Name of images section in multiple choice table")
        } else if section == _sectionComments {
            return NSLocalizedString("Comments", comment: "Title for comments section in multiple choice table factory")
        }
        return ""
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isUsingDisplayLabel() && indexPath.section == self._sectionPleaseSelectOrTitle && indexPath.row == 0 {
            return 80
        }
        if indexPath.section == _sectionComments {
            return 160
        }
        return 44
    }
    
    // numberOfRowsInSection
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var ret = 0
        if section == self._sectionPleaseSelectOrTitle {
            if let f = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
                ret = f.values.count
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
                ret = f.values.count
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
                ret = f.values.count
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, String.self) {
                ret = f.values.count
            }
            
            let isRadioOrCheckBoxWithOther = MiscHelpers.IsRadioOrCheckboxWithOther(_entryField)
            let hasAddedOther = MiscHelpers.HasAddedOtherValue(_entryField)
            
            //TODO:HasOthedOtherValue does not work for type string
            
            if isRadioOrCheckBoxWithOther && !hasAddedOther {
                ret += 1
            }
            
            if ret == 0 && isRadioOrCheckBoxWithOther && hasAddedOther {
                ret += 1
            }
            
            if _displayLabel.count > 0 {
                ret = ret + 1
            }
            
        } else if section == self._sectionImages {
            if let f = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
                ret = f.attachments.count
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
                ret = f.attachments.count
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
                ret = f.attachments.count
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, String.self) {
                ret = f.attachments.count
            }
        } else if section == _sectionComments {
            return 1
        }
        
        return ret
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        //TODO:This part will be called only after having added Other value and now we want to change it
        NSLog("TODO:This part will be called only after having added Other value and now we want to change it")
    }
    //Cell Setup
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.section == self._sectionPleaseSelectOrTitle {
            if isUsingDisplayLabel() && indexPath.row == 0 {
                var c: DisplayLabelViewCell? = .none
                if let cDeque = tableView.dequeueReusableCell(withIdentifier: _textCellIdentifier) as? DisplayLabelViewCell {
                    c = cDeque
                } else {
                    c = getDisplayLabelCell()
                }
                if let cc = c {
                    cc.displayLabel.text = self._displayLabel
                    return cc
                }
                
            } else {
                var c: RadioCheckboxViewCell? = .none
                if let cDeque = tableView.dequeueReusableCell(withIdentifier: _textCellIdentifier) as? RadioCheckboxViewCell {
                    c = cDeque
                } else {
                    c = getOwnCell()
                }
                
                if let cc = c {
                    if let f = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
                        styleCell(cc, indexPath: indexPath, f: f)
                    } else if let f = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
                        styleCell(cc, indexPath: indexPath, f: f)
                    } else if let f = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
                        styleCell(cc, indexPath: indexPath, f: f)
                    } else if let f = MiscHelpers.CastEntryFormField(_entryField, String.self) {
                        styleCell(cc, indexPath: indexPath, f: f)
                    }
                    
                    return cc
                }
            }
        } else if indexPath.section == self._sectionImages {
            var c: ImageEntryFormCell? = .none
            if let cDeque = tableView.dequeueReusableCell(withIdentifier: _imageCellIdentifier) as? ImageEntryFormCell {
                c = cDeque
            } else {
                c = getOwnImageCell()
            }
            
            if let cc = c {
                //TODO:List attachments
                if let _ = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
                    //cc.attachedImage.image = f.attachedImages[indexPath.row]
                } else if let _ = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
                    //cc.attachedImage.image = f.attachedImages[indexPath.row]
                } else if let _ = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
                    //cc.attachedImage.image = f.attachedImages[indexPath.row]
                } else if let _ = MiscHelpers.CastEntryFormField(_entryField, String.self) {
                    //cc.attachedImage.image = f.attachedImages[indexPath.row]
                }
                
                return cc
            }
        } else if indexPath.section == _sectionComments {
            var c:CommentsViewCell? = .none
            if let cDeque = tableView.dequeueReusableCell(withIdentifier: _commentsCellIdentifier) as? CommentsViewCell {
                c = cDeque
            } else {
                c = getCommentsCell()
            }
            
            if let cc = c {
                var existingComments: String = ""
                if let f = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
                    if let c = f.fieldComments?.value {
                        existingComments = c
                    }
                } else if let f = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
                    if let c = f.fieldComments?.value {
                        existingComments = c
                    }
                } else if let f = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
                    if let c = f.fieldComments?.value {
                        existingComments = c
                    }
                } else if let f = MiscHelpers.CastEntryFormField(_entryField, String.self) {
                    if let c = f.fieldComments?.value {
                        //orientated entry field
                        if displayComments, orientatedEntryField {
                            if c.isEmpty {
                                existingComments = ""
                            } else {
                                existingComments = c
                            }
                        } else {
                            //for other entryFields
                        existingComments = c
                        }
                        if didChangeSelection {
                            existingComments = ""
                        }
                    }
                }
                cc.delegate = self
                cc.commentsTextView.text = existingComments
                return cc
            }
        }
        
        return UITableViewCell()
    }
    
    //Cell Style
    func styleCell<T>(_ cell: RadioCheckboxViewCell, indexPath: IndexPath, f: EntryFormBaseFieldType<T>) {
        var s: String = ""
        cell.accessoryType = UITableViewCell.AccessoryType.none
        let valuesCnt = f.values.count
        let r = isUsingDisplayLabel() ? indexPath.row - 1 : indexPath.row
        
        if r >= valuesCnt {
            s = "Other..."
            if !f.displaySelectedValue().isEmpty {
                cell.detailTextLabel?.text = f.displaySelectedValue()
            }
            cell.setValueSelected(false)
        } else {
            let value = f.values[r]
            s = value.1
            
            cell.setValueSelected(self._cellsState[r]!)
            
            let isRadioOrCheckboxWithOther = MiscHelpers.IsRadioOrCheckboxWithOther(f)
            let isOnLastCellRow = valuesCnt == r + 1
            
            if isRadioOrCheckboxWithOther && MiscHelpers.HasAddedOtherValue(_entryField) && isOnLastCellRow {
                cell.accessoryType = UITableViewCell.AccessoryType.detailDisclosureButton
            }
            
            if isRadioOrCheckboxWithOther && !f.displaySelectedValue().isEmpty {
                cell.detailTextLabel?.text = f.displaySelectedValue()
            }
        }
        cell.optionTitle.text = s
        cell.setImagesAsRadio(MiscHelpers.IsRadio(f))
    }
    
    //didSelect
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if indexPath.section == self._sectionPleaseSelectOrTitle {
            if isUsingDisplayLabel() && indexPath.row == 0 {
                return
            }
            if let f = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
                selectUnselectValueForIndexPath(indexPath, f: f)
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
                selectUnselectValueForIndexPath(indexPath, f: f)
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
                selectUnselectValueForIndexPath(indexPath, f: f)
                //case yes/no radio buttons
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, String.self) {
                selectUnselectValueForIndexPath(indexPath, f: f)
            }
            if let selection = _cellsState[indexPath.row] {
                if indexPath.row == 1 {
                    displayComments = selection
                    didChangeSelection = true
                }
                if indexPath.row == 0 {
                    displayComments = !selection
                    didChangeSelection = true
                }
            }
            print("\(self) \(indexPath.row)")
            
            print(indexPath.section)
            
        }
    }
    
    open func SelectValue() {
        if let indexPath = self.lastIndex, indexPath.section == 0 {
            if let f = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
                confirmSelectionForIndexPath(f)
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
                confirmSelectionForIndexPath(f)
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
                confirmSelectionForIndexPath(f)
            } else if let f = MiscHelpers.CastEntryFormField(_entryField, String.self) {
                confirmSelectionForIndexPath(f)
            }
        }
    }
    
    func confirmSelectionForIndexPath<T>(_ f: EntryFormBaseFieldType<T>) {
        for (_, el) in self._cellsState.enumerated() {
            let value = f.values[el.0]
            
            if el.1 {
                f.selectValue(value)
            } else {
                f.unselectValue(value)
            }
        }
    }
    
    //populate cell state _cellsState
    func selectUnselectValueForIndexPath<T>(_ indexPath: IndexPath, f: EntryFormBaseFieldType<T>) {
        self.lastIndex = indexPath
        let r = isUsingDisplayLabel() ? indexPath.row - 1 : indexPath.row
        if r >= f.values.count {
            //add Other value
            if let d = _delegate {
                d.enterValueForOther(f)
            }
        } else {
            if let tv = _tableView {
                if _isRadioType {
                    if let _ = lastIndex {
                        for (_, el) in _cellsState.enumerated() {
                            _cellsState[el.0] = r == el.0
                        }
                    }
                }
                
                if let _ = self.lastIndex, !self._isRadioType {
                    self._cellsState[r] = !self._cellsState[r]!
                }
                
                if MiscHelpers.IsRadio(f) {
                    tv.reloadData()
                } else {
                    tv.beginUpdates()
                    tv.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                    tv.endUpdates()
                }
            }
        }
    }
    
    func isUsingDisplayLabel() -> Bool {
        return self._displayLabel.count > 0
    }
    
    open func commentsHaveChnaged(_ newComments: String) {
        if let f = MiscHelpers.CastEntryFormField(_entryField, Int.self) {
            f.addFieldComments(newComments)
        } else if let f = MiscHelpers.CastEntryFormField(_entryField, Float.self) {
            f.addFieldComments(newComments)
        } else if let f = MiscHelpers.CastEntryFormField(_entryField, Double.self) {
            f.addFieldComments(newComments)
        } else if let f = MiscHelpers.CastEntryFormField(_entryField, String.self) {
            f.addFieldComments(newComments)
        }
    }
}

