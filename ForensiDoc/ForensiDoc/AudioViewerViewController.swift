//
//  AudioViewerViewController.swift
//  ForensiDoc

import Foundation
import UIKit
import AVKit
import AVFoundation


open class AudioViewerViewController: BaseViewController, AVAudioPlayerDelegate {
    @IBOutlet var customNavigationBar: UINavigationBar!
    
    open var AudioUrl: URL!
    open var AudioTitle: String!
    var audioPlayer: AVAudioPlayer!
    var loadedOnlyOnce = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.customNavigationBar.topItem?.title = self.AudioTitle
        let doneBtn = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done button on attachments viewer"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneTapped(_:)))
        self.customNavigationBar.topItem?.rightBarButtonItem = doneBtn
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loadedOnlyOnce {
            loadedOnlyOnce = true
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: self.AudioUrl)
                audioPlayer.prepareToPlay()
                audioPlayer.volume = 1.0
                audioPlayer.delegate = self
                audioPlayer.play()
            } catch {
                //TODO:Display error message here
            }
        }
    }
    
    func doneTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: .none)
    }
    
}
