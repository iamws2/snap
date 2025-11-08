import SwiftUI

@main
struct Test2App: App {
    @AppStorage("isUnlocked") var isUnlocked: Bool = false
    @State private var needsPasscodeSetup: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    init() {
        // 通知のデリゲートを初期化して設定する（←これが重要）
        _ = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView(isUnlocked: $isUnlocked, needsPasscodeSetup: $needsPasscodeSetup)
                .onAppear {
                    // 起動時にパスコード未設定かどうかをチェック
                    needsPasscodeSetup = (KeychainHelper.shared.getPasscode() == nil)
                    // 初期状態ではロック
                    isUnlocked = false
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .background || scenePhase == .inactive {
                        // アプリが非アクティブ・バックグラウンドに移行したらロック
                        isUnlocked = false
                    }
                }
        }
    }
}
