import SwiftUI

struct StorableImage: Identifiable, Codable {
    let id: UUID
    let imageData: Data
    var result: String
    var hashtags: [String]
    var filename: String?
    var assetIdentifier: String?
    
    // リマインダー情報も保存する
    //var reminderDate: Date?
    
    init(from classified: ClassifiedImage) {
        self.id = classified.id
        self.imageData = classified.image.jpegData(compressionQuality: 0.8) ?? Data()
        self.result = classified.result
        self.hashtags = classified.hashtags
        self.filename = classified.filename
        self.assetIdentifier = classified.assetIdentifier
       // self.reminderDate = classified.reminderDate
    }

    func toClassifiedImage() -> ClassifiedImage {
        return ClassifiedImage(
            id: self.id,
            image: UIImage(data: imageData) ?? UIImage(),
            result: self.result,
            hashtags: self.hashtags,
            filename: self.filename,
            assetIdentifier: self.assetIdentifier
            //reminderDate: self.reminderDate
            )
    }
}

