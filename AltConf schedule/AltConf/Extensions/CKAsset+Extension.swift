//
//  CKAsset+Extension.swift
//  AltConf
//
//  Created by Jeroen Zonneveld on 24-05-18.
//  Copyright © 2018 Jeroen Zonneveld. All rights reserved.
//

import Foundation
import CloudKit

extension CKAsset {
    var image: UIImage? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
    }
}
