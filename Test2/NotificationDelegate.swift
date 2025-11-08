
import UserNotifications
import SwiftUI

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationDelegate()
    
    @Published var deliveredNotifications: [String] = [] // 通知IDを管理（必要に応じて）

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // フォアグラウンドでも通知を表示
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }

    // 通知タップ時など
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let id = response.notification.request.identifier
        DispatchQueue.main.async {
            self.deliveredNotifications.append(id)
        }
    }
}
