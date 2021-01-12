//
//  EntryBaseFormGroup.swift
//  BitmelterEntryForm

import Foundation

open class EntryBaseFormGroup {
    private var _id: String = ""
    private var _fields: [Any] = []
    private var _title: String = ""
    fileprivate var _group: String = ""

    open var title: String {
        get {
            return _title
        }
    }
    
    open var fields: [Any] {
        get {
            return _fields
        }
    }
    
    open var Id: String {
        get {
            return _id
        }
    }
    
    open var group: String {
        get {
            return _group
        }
    }
    
}
