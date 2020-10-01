//
//  BitmelterAccountManager.swift
//  BitmelterAccount

import Foundation

public protocol BitmelterAccountManagerProtocol {
    func UsingUsernameAndPassword() -> Bool
}

struct Singleton {
    static let instance = BitmelterAccountManager()
}

open class BitmelterAccountManager {
    var _onSuccessfullLogon: (() -> Void)? = .none
    var _onSuccessfullPasscode: (() -> Void)? = .none
    var _onSuccessfullAccountActivation: (() -> Void)? = .none
    var _onSuccessfullPasswordReset: (() -> Void)? = .none
    var _delegate: BitmelterAccountManagerProtocol? = .none
 
    //MARK: fix2020
    class open func startSharedInstance(_ delegate: BitmelterAccountManagerProtocol?) {//-> BitmelterAccountManager {
        let instance = Singleton.instance
        instance._delegate = delegate
       // return instance
    }
    
    class open var sharedInstance: BitmelterAccountManager {
        let instance = Singleton.instance
        return instance
    }
    
    open var UsingUsernameAndPassword: Bool {
        get {
            if let delegate = self._delegate {
                return delegate.UsingUsernameAndPassword()
            }
            return false
        }
    }
    
    open func onSuccessfullPasswordReset(_ callback:(() -> Void)?){
        _onSuccessfullPasswordReset = callback
    }
    
    func triggerSuccessfullPasswordreset(){
        _onSuccessfullPasswordReset?()
    }
    
    open func onSuccessfullLogon(_ callback:(() -> Void)?){
        _onSuccessfullLogon = callback
    }
    
    open func triggerSuccessFullLogon(){
        _onSuccessfullLogon?()
    }
    
    open func onSuccessfullPasscode(_ callback:(() -> Void)?){
        _onSuccessfullPasscode = callback
    }
    
    func triggerSuccessfullPasscode(){
        _onSuccessfullPasscode?()
    }
    
    open func onSuccessfullAccountActivation(_ callback:(() -> Void)?){
        _onSuccessfullAccountActivation = callback
    }
    
    func triggerSuccessfullAccountActivation(){
        _onSuccessfullAccountActivation?()
    }
}
