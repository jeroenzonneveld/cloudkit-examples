//
//  TalkTableViewCell.swift
//  AltConf
//
//  Created by Jeroen Zonneveld on 22-05-18.
//  Copyright © 2018 Jeroen Zonneveld. All rights reserved.
//

import Foundation
import UIKit

final class TalkTableViewCell: UITableViewCell {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var speakerLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var locationLabel: UILabel!
    @IBOutlet weak private var speakerImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        speakerImage.clipsToBounds = true
        speakerImage.layer.cornerRadius = speakerImage.frame.size.height / 2
    }
    
    var talk: ACTalk? {
        didSet {
            setCellLabels()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        speakerLabel.text = nil
        timeLabel.text = nil
        locationLabel.text = nil
        speakerImage.image = nil
    }
    
    func setCellLabels() {
        titleLabel.text = talk?.title
        speakerLabel.text = talk?.speaker
        locationLabel.text = talk?.location
        
        speakerImage.image = talk?.speakerImage
        
        guard let date = talk?.date else { return }
        let hours = Calendar.current.component(.hour, from: date)
        let minutes = Calendar.current.component(.minute, from: date)
        
        timeLabel.text = String(format: "%0.2d:%0.2d", hours, minutes)
    }
}
