import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Binding var isUnlocked: Bool
    @AppStorage("tagNotificationEnabled") var tagNotificationEnabled = true
    @State private var showSetPasscode = false

    var body: some View {
        Form {
            Section(header: Text("セキュリティ")) {
                Button("パスコードを変更") {
                    showSetPasscode = true
                }
                .sheet(isPresented: $showSetPasscode) {
                    SetPasscodeView(isUnlocked: $isUnlocked)
                }
            }
            
            Section(header: Text("タグ整理通知")) {
                Toggle("タグ整理通知を有効にする", isOn: $tagNotificationEnabled)
                    .onChange(of: tagNotificationEnabled) { enabled in
                        if enabled {
                            requestNotificationPermission()
                        } else {
                            // タグ通知のキャンセル
                            cancelTagNotifications()
                        }
                    }
            }
        }
        .navigationTitle("設定")
        .onAppear {
            checkNotificationStatus()
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    tagNotificationEnabled = false
                }
            }
        }
    }

    private func cancelTagNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let tagRequests = requests.filter { $0.identifier.starts(with: "tagRecommendation-") }
            let ids = tagRequests.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    tagNotificationEnabled = false
                }
            }
        }
    }
}
