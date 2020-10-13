//
//  PickerTextField.swift
//  ForensiDoc
//
//  Created by   admin on 13.10.2020.
//  Copyright © 2020 Bitmelter Ltd. All rights reserved.
//

import Foundation
import UIKit
protocol PickerTextFieldDelegate: class {
    func updateWithSelection(string: String)
}

class PickerTextField: UITextField, UIPickerViewDataSource {
    
    private let pickerView = UIPickerView()
    var pickerData: [Int] = [1,2,3,4,5]
    weak var updater: PickerTextFieldDelegate?
  //  weak var updateResultsDelegate: StationsTextFieldDelegate?
  //  let stations = DataCollector.shared.stations
    
    
    init() {
        
      //  pickerData = (stations != nil) ? stations!.stations : []
        super.init(frame: CGRect())
        
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 44.0)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonAction))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [doneButton, space]
        
        self.inputAccessoryView = toolBar
                
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.inputView = pickerView
//        pickerView.selectRow(0, inComponent: 0, animated: false)
//        pickerView.reloadAllComponents()
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func doneButtonAction() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        print("selectedRow: \(selectedRow)")
       // pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        var text = ""
        if pickerData.count > 0 {
            text = "\(pickerData[selectedRow])"
        } else {
            text = ""
        }
        self.updater?.updateWithSelection(string: text)
      //  self.updateResultsDelegate?.updateWithSelection(string: text)
        self.text = text
        self.resignFirstResponder()
    }
    
//    //MARK: - Get Stations from DataCollector
//    func updateStationsList() {
//         self.pickerData.removeAll()
//        if DataCollector.shared.stations != nil {
//
//            self.pickerData = DataCollector.shared.stations!.stations
//
//        }
//        pickerView.reloadAllComponents()
//    }
    
}

extension PickerTextField: UIPickerViewDelegate {
    // MARK: UIPickerView Delegation

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row])"
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("didSelectRow \(row)")
        //self.text = pickerData[row].name
    }
    
}
