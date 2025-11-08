//リマインダー機能
/*import SwiftUI
import UserNotifications

struct ReminderView: View {
    @Binding var isPresented: Bool
    @Binding var reminderSet: Bool
    @Binding var setDate: Date?

    @State private var reminderDate: Date = Date()

    init(isPresented: Binding<Bool>, reminderSet: Binding<Bool>, setDate: Binding<Date?>) {
        self._isPresented = isPresented
        self._reminderSet = reminderSet
        self._setDate = setDate
        // setDateの値があれば初期化に使う
        _reminderDate = State(initialValue: setDate.wrappedValue ?? Date())
    }

    var body: some View {
        if isPresented {
            VStack {
                DatePicker("日時を選択", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                HStack {
                    Button("キャンセル") {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .padding()
                    Spacer()
                    Button("設定") {
                        if reminderDate > Date() {
                            scheduleNotification(at: reminderDate)
                            setDate = reminderDate
                            reminderSet = true
                            withAnimation {
                                isPresented = false
                            }
                        } else {
                            // Optional: ユーザーに警告を出す
                            print("過去の日時には通知を設定できません")
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding()
        }
    }

    func scheduleNotification(at date: Date) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted && error == nil {
                let content = UNMutableNotificationContent()
                content.title = "リマインダー"
                content.body = "設定した時間になりました。"
                content.sound = .default

                // 秒を0に設定する例
                var triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                triggerDateComponents.second = 0

                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        }
    }
}*/
