//
//  EntryFormImageWithTitle.swift
//  BitmelterEntryForm

import Foundation

open class EntryFormImageWithTitle {
    open var title: String
    open var imageName: String
    fileprivate var canDisplay: Bool
    open var formula: String
    var allFields:[String:Any?] = [String:Any?]()
    
    public init(title: String, imageName: String, formula: String) {
        self.title = title
        self.imageName = imageName
        self.canDisplay = true
        self.formula = formula
    }
    
    open var eventManager: EventManager? {
        didSet {
            if self.formula.count > 0 {
                self.canDisplay = false
                let extractedFields = MiscHelpers.ExtractFieldsFromFormula(formula)
                for extractedField in extractedFields {
                    self.allFields[extractedField] = ""
                    NSLog("%@", self.allFields.description)
                    self.eventManager?.listenTo(extractedField, action: { (information: Any?) -> () in
                        self.canDisplay = MiscHelpers.CalculateExpression(&self.allFields, fieldId: extractedField, value: information, formula: self.formula)
                    })
                }
            }
        }
    }
    
    open var CanDisplay: Bool {
        get {
            return canDisplay
        }
    }
}
