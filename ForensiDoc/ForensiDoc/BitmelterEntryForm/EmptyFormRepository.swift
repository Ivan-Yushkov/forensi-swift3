//
//  EmptyFormRepository.swift
//  BitmelterEntryForm

import Foundation

internal class EmptyFormRepository : EntryFormRepository{
    internal func LoadJSONFormSpecs() -> Array<String>{
        return Array<String>()
    }
    
    internal func LoadSavedFormForFormId(_ formId: Int) -> Array<EntryForm> {
        return [EntryForm]()
    }
    
    internal func SaveEntryForm(_ form: EntryForm) -> Bool {
        return true
    }
    
    internal func DeleteEntryForm(_ form: EntryForm) {
        
    }
}
