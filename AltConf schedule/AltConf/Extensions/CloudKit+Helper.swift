import Foundation
import UIKit
import CloudKit

extension CKAsset {
    convenience init(image: UIImage, fileType: ImageFileType = .JPG(compressionQuality: 70)) throws {
        let url = try image.saveToTempLocation(with: fileType)
        self.init(fileURL: url as URL)
    }
    
    var image: UIImage? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        return image
    }
}

enum ImageFileType {
    case JPG(compressionQuality: CGFloat)
    case PNG
    
    var fileExtension: String {
        switch self {
        case .JPG(_):
            return ".jpg"
        case .PNG:
            return ".png"
        }
    }
}

enum ImageError: Error {
    case unableToConvertImageToData
}

extension UIImage {
    func saveToTempLocation(with fileType: ImageFileType) throws -> URL {
        let imageData: Data?
        
        switch fileType {
        case .JPG(let quality):
            imageData = UIImageJPEGRepresentation(self, quality)
        case .PNG:
            imageData = UIImagePNGRepresentation(self)
        }
        guard let data = imageData else {
            throw ImageError.unableToConvertImageToData
        }
        
        let filename = ProcessInfo.processInfo.globallyUniqueString + fileType.fileExtension
        let url = NSURL.fileURL(withPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        try data.write(to: url)
        
        return url
    }
}
