//
//  BitmelterEntryFormRepository.swift
//  BitmelterEntryForm

import Foundation

public protocol EntryFormRepository {
    func LoadJSONFormSpecs() -> [String]
    func LoadSavedFormForFormId(_ formId: Int) -> [EntryForm]
    func SaveEntryForm(_ form: EntryForm) -> Bool
    func DeleteEntryForm(_ form: EntryForm)
}
