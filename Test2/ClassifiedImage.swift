import SwiftUI
import UserNotifications

struct ClassifiedImage: Identifiable, Equatable {
    let id: UUID
    var image: UIImage
    var result: String
    var hashtags: [String]
    var filename: String?
    var assetIdentifier: String?
    
    /*var reminderDate: Date? = nil
    var reminderSet: Bool {
        reminderDate != nil
    }*/

    init(id: UUID = UUID(),
         image: UIImage,
         result: String = "分類中…",
         hashtags: [String] = [],
         filename: String? = nil,
         assetIdentifier: String? = nil,
         reminderDate: Date? = nil) {
        self.id = id
        self.image = image
        self.result = result
        self.hashtags = hashtags
        self.filename = filename
        self.assetIdentifier = assetIdentifier
        //self.reminderDate = reminderDate
    }
    /*func scheduleNotification() {
        guard let date = reminderDate, date > Date() else { return }

        let identifier = id.uuidString // self.id をクロージャ外で保持

        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }

            let content = UNMutableNotificationContent()
            content.title = "リマインダー"
            content.body = "設定した時間になりました"
            content.sound = .default

            var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            components.second = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            center.add(request)
        }
    }

    
    mutating func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        reminderDate = nil
    }*/
}
