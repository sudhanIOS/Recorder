//
//  ViewController.swift
//  func
//
//  Created by Hariharasudhan J on 09/02/21.
//

import UIKit
import AVFoundation

var recordButton: UIButton!
var playButton: UIButton!
var slider: UISlider!


var recordingSession: AVAudioSession!
var whistleRecorder: AVAudioRecorder!
var audioPlayer : AVAudioPlayer?


class ViewController: UIViewController {
    
    @IBOutlet weak var sliderNew: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "What's that Whistle?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
    }
    @objc func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

