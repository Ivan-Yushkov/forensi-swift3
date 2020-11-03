//
//  LocationFieldTypeViewController.swift
//  ForensiDoc

import Foundation
import what3words
import CoreLocation

class LocationFieldTypeViewController: BaseViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var progressAlert: UIAlertController?
    
    @IBOutlet var textView: UITextView!
    
    
    var _entryField: Any?
    
    @IBAction func getLocationTapped(_ sender: AnyObject) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        AlertHelper.DisplayProgress(self, title: NSLocalizedString("Please wait", comment: "Please wait dialog title"), messages: [NSLocalizedString("Getting your location", comment: "Title when getting location of the user in order to get address")], cancelCallback: {
                self.locationManager.stopUpdatingLocation()
            }) { (alert) in
                if alert is UIAlertController {
                    self.progressAlert = (alert as! UIAlertController)
                }
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func useMapToGetLocationTapped(_ sender: AnyObject) {
        
    }
    
    func setEntryField<T: EntryFormFieldContainer>(_ entryField: T) {
        _entryField = entryField
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        W3wGeocoder.setup(with: "N9X72HJK")
        
        let doneButton: UIBarButtonItem? = ViewsHelpers.GetDoneButton(#selector(LocationFieldTypeViewController.endEditing(_:)), target: self)
        
        if let ef = _entryField {
            if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                self.title = f.title
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                self.title = f.title
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                self.title = f.title
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                self.title = f.title
                self.checkIfCanAttachPhotos(f.attachmentsSpec, addAttachmentAction: EntryFormAttachmentAddAction(action: self.addAttachment),entryFormField: f, doneButton: doneButton, attachmentsHeightConstraint: self.attachmentsSelectorViewHeightConstraint,numberOfAttachments: f.attachments.count)
            }
        }
        
        // Would be nice to add this from fucking interface builder
        ViewsHelpers.FormatTextView(self.textView, makeFirstResponder: false)
        //self.automaticallyAdjustsScrollViewInsets = false
        if let ef = self._entryField {
            if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                let displayAddress = f.displaySelectedValue().replacingOccurrences(of: ",", with: "\n")
                self.textView.text = displayAddress
            }
        }
    }
    
    @objc func endEditing(_ sender: AnyObject) {
        if let doneEditingWrapper = self.doneEditing, self.textView.text.count == 0 {
            if let allowEmptyData = doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.allowEmptyData(), allowEmptyData == false {
                AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error title dialog when entered empty data"), messages: [NSLocalizedString("You cannot leave that field empty if you want to save it.", comment: "Error message on error dialog when entered no data.")], callback: .none)
                return
            }
        }
        
        let addedValue = processTextViewToEntryField(self.textView)
        if addedValue {
            if let doneEditingWrapper = self.doneEditing {
                if let ef = self._entryField, let eForm = self.entryForm {
                    if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                        doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                    } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                        doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                    } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                        doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                    } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                        doneEditingWrapper.EntryFormFieldDoneEditingDelegate?.handleEditedForm(eForm, entryFormField: f)
                    }
                }
            }
            if ViewsHelpers.IsiPad() {
                if let svc = self.splitViewController {
                    svc.showDetailViewController(self.GetEmptyViewForDetailView(), sender: self)
                }
            } else {
                DispatchQueue.main.async(execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        } else {
            //popup error message
        }
    }
    
    func processTextViewToEntryField(_ textView: UITextView) -> Bool {
        var addedValue = false
        if let ef = _entryField {
            if let f = MiscHelpers.CastEntryFormField(ef, Int.self) {
                addedValue = addValue(f, textView: textView)
            } else if let f = MiscHelpers.CastEntryFormField(ef, String.self) {
                addedValue = addValue(f, textView: textView)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Float.self) {
                addedValue = addValue(f, textView: textView)
            } else if let f = MiscHelpers.CastEntryFormField(ef, Double.self) {
                addedValue = addValue(f, textView: textView)
            }
        }
        return addedValue
    }
    
    func addValue<T>(_ formField: EntryFormBaseFieldType<T>, textView: UITextView) -> Bool {
        
        formField.values.removeAll(keepingCapacity: true)
        
        let lines = textView.text.components(separatedBy: "\n")
        
        for line in lines {
            let added = formField.addValue(line, title: line)
            if !added {
                return false
            }
        }
        
        return true
    }
    
    func addAttachment(_ attachment: EntryFormAttachment, attachmentsViewer: AttachmentsSelectorView?) {
      _ = ViewsHelpers.HandleAttachments(_entryField, attachment: attachment, attachmentsViewer: attachmentsViewer)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let location = manager.location {
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)-> Void in
                if (error != nil) {
                    self.CloseCurrentProgress()
                    AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [error!.localizedDescription], callback: {() -> Void in
                    })
                    return
                }
                
                if let address = placemarks?.first, address.addressDictionary != nil {
                    self.displayLocationInfo(address, location)
                } else {
                    
                }
            })
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        CloseCurrentProgress()
        AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [error.localizedDescription], callback: .none)
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark, _ location: CLLocation) {
        CloseCurrentProgress()
        locationManager.stopUpdatingLocation()
        if let myAddressDictionary: [AnyHashable: Any] = placemark.addressDictionary, let myAddressStrings = myAddressDictionary["FormattedAddressLines"]
        {
            let displayAddress = (myAddressStrings as AnyObject).componentsJoined(by: "\n")
            
            let lon = location.coordinate.longitude
            let lat = location.coordinate.latitude
            let output = displayAddress + "\n" + "Lon: \(lon)\n" + "Lat: \(lat)\n"
            self.textView.text = output
            W3wGeocoder.shared.convertTo3wa(coordinates: location.coordinate) { [weak self] (place, error) in
                guard let place = place else { return }
                print(place.words)
                
                DispatchQueue.main.async {
                    self?.textView.text = output + "\(place.words)\n" + "\(place.map)"
                }
                
            }
        } else {
            AlertHelper.DisplayAlert(self, title: NSLocalizedString("Error", comment: "Error dialog title"), messages: [NSLocalizedString("Unable to get get current address", comment: "Error message displayed when trying to use reverse geocoder to get address and could not format it")], callback: .none)
        }
    }
    
    func CloseCurrentProgress() {
        if let a = self.progressAlert {
            a.dismiss(animated: true, completion: .none)
        }
    }
}
