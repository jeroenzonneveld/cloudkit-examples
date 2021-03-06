//
//  ACTalk.swift
//  AltConf
//
//  Created by Jeroen Zonneveld on 24-05-18.
//  Copyright © 2018 Jeroen Zonneveld. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

struct ACTalk {
    var record: CKRecord?
    
    var title: String?
    var speaker: String?
    var date: Date?
    var location: String?
    var speakerImage: UIImage?
}
