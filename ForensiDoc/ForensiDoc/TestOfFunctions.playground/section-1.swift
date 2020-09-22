// Playground - noun: a place where people can play

import UIKit

class BaseViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class RegisterForNewAccountViewController: BaseViewController {
    
}

var str = "Hello, playground"

func navigateToView<T: UIViewController>(type: T?)->String?{
    let name: String = NSStringFromClass(T.self)
    let range = name.rangeOfString(".", options: .BackwardsSearch)
    var viewName:String?
    if let range = range {
        viewName = name.substringFromIndex(range.endIndex)
    } else {
        viewName = name
    }
    
    let controllerRange = viewName?.rangeOfString("Controller", options: .BackwardsSearch)
    if let controllerRange = controllerRange {
        viewName = viewName?.substringToIndex(controllerRange.startIndex)
    }
    
    return viewName
}

let registerForNewAccount:RegisterForNewAccountViewController? = nil;
var dd = navigateToView(registerForNewAccount)


