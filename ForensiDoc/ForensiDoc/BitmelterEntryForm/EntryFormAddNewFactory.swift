//
//  BitmelterEntryFormAddNewFactory.swift
//  BitmelterEntryForm

import Foundation

public protocol EntryFormAddNewFactoryProtocol {
    func getTableView(_ entryFormField: Any) -> UITableViewCell?
    func viewSubGroupForEntryFormGroup(_ entryForm: EntryForm, entryFormGroup: EntryFormGroup)
    func viewFormField(_ entryForm: EntryForm, formField: Any)
    func informAboutCalculatedField(_ message: String)
    func viewDrawableFormField(_ entryForm: EntryForm, entryFormDrawable: EntryFormDrawable)
    func viewAttachmentsForEntryForm(_ entryForm: EntryForm)
}

open class EntryFormAddNewFactory: NSObject, UITableViewDataSource, UITableViewDelegate {
    fileprivate let _tableViewDataSource: UITableViewDataSource? = .none
    fileprivate var _tableView: UITableView? = .none
    fileprivate let _delegate: EntryFormAddNewFactoryProtocol?
    fileprivate var _entryForm: EntryForm
    fileprivate var _subGroup: EntryFormGroup?
    fileprivate let _textCellIdentifier: String
    
    public init(entryForm: EntryForm, subGroup: EntryFormGroup?, tableView: UITableView?, delegate: EntryFormAddNewFactoryProtocol?){
        _delegate = delegate
        _textCellIdentifier = MiscHelpers.RandomStringWithLength(10)
        _entryForm = entryForm
        _subGroup = subGroup
        _tableView = tableView
    }
    
    fileprivate var _lastIndex: IndexPath? = .none
    fileprivate var lastIndex: IndexPath? {
        get{
            let ret: IndexPath? = _lastIndex
            _lastIndex = .none
            return ret
        }
        set{
            _lastIndex = newValue
        }
    }
    
    open func shouldRefresh(){
        if let li = self.lastIndex, let tbl = _tableView {
            tbl.reloadRows(at: [li], with: UITableView.RowAnimation.automatic)
            //Check for calculated fields
            var cnt = 0
            for field in fields() {
                if MiscHelpers.IsCalculatedField(field) {
                    let indexPath = IndexPath(row: cnt, section: 0)
                    tbl.reloadRows(at: [indexPath], with: .automatic)
                }
                cnt += 1
            }
        } else if let tbl = _tableView {
            tbl.reloadData()
        }
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var ret = fields().count
        if let _ = _subGroup {
            return ret
        }
        
        if self._entryForm.Attachments.count > 0 {
            ret += 1
        }
        return ret
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let d = _delegate {
            if self.isOnAttachmentsRow(indexPath) {
                if let c = d.getTableView(_entryForm.Attachments) {
                    return c
                }
            } else {
                if let c = d.getTableView(fields()[indexPath.row]) {
                    return c
                }
            }
        }
//MARK: fix2020
        //var eff: Any? = .none
        var eff: Any?
        var cellIdentifierSuffix = ""
        if !self.isOnAttachmentsRow(indexPath) {
            eff = fields()[indexPath.row]
            if eff != nil {
            if let e = MiscHelpers.CastEntryFormField(eff!, Int.self) {
                cellIdentifierSuffix = e.id
            } else if let e = MiscHelpers.CastEntryFormField(eff!, Double.self) {
                cellIdentifierSuffix = e.id
            } else if let e = MiscHelpers.CastEntryFormField(eff!, Float.self) {
                cellIdentifierSuffix = e.id
            } else if let e = MiscHelpers.CastEntryFormField(eff!, String.self) {
                cellIdentifierSuffix = e.id
            }
            }
        }
        
        var c: UITableViewCell? = .none
        
        let cellIdentifier = "\(_textCellIdentifier)_\(cellIdentifierSuffix)"
        
        //TODO:Register cell in the constructor I guess
        if let cDeque = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            c = cDeque
        } else {
            c = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if let ret = c {
            var isCalculated = false
            if self.isOnAttachmentsRow(indexPath) {
                ret.textLabel?.text = NSLocalizedString("Attachments", comment: "Title of the row in the table displayed when form has attachments")
            } else if let entryForm = eff {
                if entryForm is EntryFormMultipleEntry {
                    let entryFormMultiple = entryForm as! EntryFormMultipleEntry
                    if entryFormMultiple.required && !entryFormMultiple.allRequiredAreValid() {
                        ret.imageView?.image = UIImage(named: "Ico-Required", in: Bundle.main, compatibleWith: .none)
                    } else {
                        ret.imageView?.image = .none
                    }
                    ret.textLabel?.text = entryFormMultiple.title
                } else if entryForm is EntryFormGroup {
                    let entryFormGroup = entryForm as! EntryFormGroup
                    if entryFormGroup.hasRequiredFields() && !entryFormGroup.allRequiredAreValid() {
                        ret.imageView?.image = UIImage(named: "Ico-Required", in: Bundle.main, compatibleWith: .none)
                    } else {
                       ret.imageView?.image = .none
                    }
                    ret.textLabel?.text = entryFormGroup.title
                } else if let f = MiscHelpers.CastEntryFormField(entryForm, Int.self) {
                    isCalculated = f.fieldType == .Calculated
                    if f.required && !f.isValidObject() {
                        ret.imageView?.image = UIImage(named: "Ico-Required", in: Bundle.main, compatibleWith: .none)
                    } else {
                        ret.imageView?.image = .none
                    }
                    ret.textLabel?.text = f.title
                    ret.detailTextLabel?.text = f.displaySelectedValue()
                } else if let f = MiscHelpers.CastEntryFormField(entryForm, Float.self) {
                    isCalculated = f.fieldType == .Calculated
                    if f.required && !f.isValidObject() {
                        ret.imageView?.image = UIImage(named: "Ico-Required", in: Bundle.main, compatibleWith: .none)
                    } else {
                        ret.imageView?.image = .none
                    }
                    ret.textLabel?.text = f.title
                    ret.detailTextLabel?.text = f.displaySelectedValue()
                } else if let f = MiscHelpers.CastEntryFormField(entryForm, String.self) {
                    isCalculated = f.fieldType == .Calculated
                    if f.required && !f.isValidObject() {
                        ret.imageView?.image = UIImage(named: "Ico-Required", in: Bundle.main, compatibleWith: .none)
                    } else {
                        ret.imageView?.image = .none
                    }
                    ret.textLabel?.text = f.title
                    ret.detailTextLabel?.text = f.displaySelectedValue()
                } else if let f = MiscHelpers.CastEntryFormField(entryForm, Double.self) {
                    isCalculated = f.fieldType == .Calculated
                    if f.required && !f.isValidObject() {
                        ret.imageView?.image = UIImage(named: "Ico-Required", in: Bundle.main, compatibleWith: .none)
                    } else {
                        ret.imageView?.image = .none
                    }
                    ret.textLabel?.text = f.title
                    ret.detailTextLabel?.text = f.displaySelectedValue()
                } else if entryForm is EntryFormDrawable {
                    let entryFormDrawable = entryForm as! EntryFormDrawable
                    if entryFormDrawable.required && !entryFormDrawable.isValidObject() {
                        ret.imageView?.image = UIImage(named: "Ico-Required", in: Bundle.main, compatibleWith: .none)
                    } else {
                        ret.imageView?.image = .none
                    }
                    ret.textLabel?.text = entryFormDrawable.title
                }
            }
            
            if !isCalculated {
                ret.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            } else {
                ret.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            }
            
            return ret
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        shouldDisplayEntryFormForIndexPath(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        shouldDisplayEntryFormForIndexPath(indexPath)
    }
    
    fileprivate func shouldDisplayEntryFormForIndexPath(_ indexPath: IndexPath){
        if let delegate = _delegate {
            if !self.isOnAttachmentsRow(indexPath) {
                self.lastIndex = indexPath
                let ef = fields()[indexPath.row]
                
                if ef is EntryFormGroup {
                    let efg = ef as! EntryFormGroup
                    delegate.viewSubGroupForEntryFormGroup(_entryForm, entryFormGroup: efg)
                } else if ef is EntryFormDrawable {
                    let efd = ef as! EntryFormDrawable
                    delegate.viewDrawableFormField(_entryForm, entryFormDrawable: efd)
                } else {
                    if MiscHelpers.IsCalculatedField(ef) {
                        var fieldNames = ""
                        var alreadyCalculated = false
                        var calculationBasedOnMultipleFields = false
                        if let f = ef as? CalculatedEntryField<Int> {
                            fieldNames = f.ExtractRealFieldNames(self._entryForm)
                            alreadyCalculated = f.canCalculate
                            calculationBasedOnMultipleFields = f.CalculationBasedOnMultipleFields()
                        } else if let f = ef as? CalculatedEntryField<Float> {
                            fieldNames = f.ExtractRealFieldNames(self._entryForm)
                            alreadyCalculated = f.canCalculate
                            calculationBasedOnMultipleFields = f.CalculationBasedOnMultipleFields()
                        } else if let f = ef as? CalculatedEntryField<Double> {
                            fieldNames = f.ExtractRealFieldNames(self._entryForm)
                            alreadyCalculated = f.canCalculate
                            calculationBasedOnMultipleFields = f.CalculationBasedOnMultipleFields()
                        } else if let f = ef as? CalculatedEntryField<String> {
                            fieldNames = f.ExtractRealFieldNames(self._entryForm)
                            alreadyCalculated = f.canCalculate
                            calculationBasedOnMultipleFields = f.CalculationBasedOnMultipleFields()
                        }
                        if fieldNames.count > 0 {
                            var message = ""
                            if alreadyCalculated {
                                message = NSLocalizedString("This field has been calculated based on\n \(fieldNames) \(calculationBasedOnMultipleFields ? "fields" : "field").", comment: "Message to popup when showing info on calculated field that has alrady been calculated.")
                            } else {
                                message = NSLocalizedString("This field will be calculated once\n \(fieldNames) \(calculationBasedOnMultipleFields ? "fields are" : "field is") populated.", comment: "Message to popup when showing info on calculated field that will be calculated.")
                            }
                            delegate.informAboutCalculatedField(message)
                        }
                    }

                    delegate.viewFormField(_entryForm, formField: ef)
                }
            } else {
                delegate.viewAttachmentsForEntryForm(_entryForm)
            }
        }
    }
    
    fileprivate func isOnAttachmentsRow(_ indexPath: IndexPath) -> Bool {
        if let _ = _subGroup {
            return false
        }
        
        return indexPath.row + 1 > fields().count
    }
    
    fileprivate func fields() -> [Any] {
        if let sb = _subGroup {
            return sb.fields
        }
        return _entryForm.Fields
    }
}
