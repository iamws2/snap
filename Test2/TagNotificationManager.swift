
import Foundation
import UserNotifications

class TagNotificationManager {
    var images: [ClassifiedImage]
    let notificationEnabledKey = "tagNotificationEnabled"

    init(images: [ClassifiedImage]) {
        self.images = images
    }

    func isNotificationEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: notificationEnabledKey)
    }

    func countImagesByTag() -> [String: Int] {
        var tagCount: [String: Int] = [:]
        for image in images {
            for tag in image.hashtags {
                tagCount[tag, default: 0] += 1
            }
        }
        return tagCount
    }

    func scheduleTagRecommendationNotification(for tag: String, count: Int) {
        guard isNotificationEnabled() else {
            print("通知OFFのためスケジュールしません")
            return
        }

        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted && error == nil {
                let content = UNMutableNotificationContent()
                content.title = "タグ整理のおすすめ"
                content.body = "\(tag) タグがついたスクショが\(count)枚あります。アルバムにまとめてみませんか？"
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                let request = UNNotificationRequest(identifier: "tagRecommendation-\(tag)", content: content, trigger: trigger)
                center.add(request)
            }
        }
    }

    func checkAndNotifyTagRecommendations() {
        guard isNotificationEnabled() else {
            cancelTagNotifications() // 通知OFFならキャンセルもする
            return
        }

        let tagCounts = countImagesByTag()
        for (tag, count) in tagCounts {
            if count >= 3 {
                scheduleTagRecommendationNotification(for: tag, count: count)
            }
        }
    }

    func cancelTagNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let tagRequests = requests.filter { $0.identifier.starts(with: "tagRecommendation-") }
            let ids = tagRequests.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
}
