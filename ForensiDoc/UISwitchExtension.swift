//
//  UISwitchExtension.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 17/02/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation

extension UISwitch {
    fileprivate struct AssociatedKeys {
        static var formInfo = "formInfo"
    }

    
    public var formInfo: EntryFormUISwitchWrapper? {
        get {
            guard let action = objc_getAssociatedObject(self, &AssociatedKeys.formInfo) as? EntryFormUISwitchWrapper else {
                return .none
            }
            return action
        }
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.formInfo,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

open class EntryFormUISwitchWrapper {
    fileprivate var _entryForm: EntryForm? = .none
    open var SelectedEntryForm: EntryForm? {
        get {
            return _entryForm
        }
        set(value) {
            _entryForm = value
        }
    }
    
    fileprivate var _selectedGroupId: String? = .none
    open var SelectedGroupId: String? {
        get {
            return _selectedGroupId
        }
        set(value){
            _selectedGroupId = value
        }
    }
}
