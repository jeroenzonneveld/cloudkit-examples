//
//  AddTalkViewController.swift
//  AltConf
//
//  Created by Jeroen Zonneveld on 29-05-18.
//  Copyright © 2018 Jeroen Zonneveld. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

final class AddTalkViewController: UIViewController {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var speakerLabel: UITextField!
    @IBOutlet weak private var talkTitleLabel: UITextField!
    @IBOutlet weak private var locationLabel: UITextField!
    @IBOutlet weak private var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add speaker"
    }
    
    @IBAction func addTalk(_ sender: UIButton) {
    
        guard let title = talkTitleLabel.text,
            let speaker = speakerLabel.text,
            let location = locationLabel.text,
            let image = imageView.image
        else { return }
        
        addTalkToDatabase(title: title as NSString, speaker: speaker  as NSString, location: location as NSString, date: datePicker.date as NSDate, image: image)
    }
    
    func addTalkToDatabase(title: NSString, speaker: NSString, location: NSString, date: NSDate, image: UIImage) {
        let activityRecord = CKRecord(recordType: "talks")
        
        activityRecord["title"] = title
        activityRecord["speaker"] = speaker
        activityRecord["location"] = location
        activityRecord["date"] = date
        
        let asset = try? CKAsset(image: image)
        activityRecord["speakerImage"] = asset
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        publicDatabase.save(activityRecord) { record, error in
            // check error
            // do complete action
        }
    }
}
