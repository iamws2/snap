
import SwiftUI

struct RootView: View {
    @Binding var isUnlocked: Bool
    @Binding var needsPasscodeSetup: Bool
    
    var body: some View {
        Group {
            if needsPasscodeSetup {
                SetPasscodeView(isUnlocked: $isUnlocked)
                    .onChange(of: isUnlocked) { newValue in
                        if newValue {
                            needsPasscodeSetup = false
                        }
                    }
            } else {
                if isUnlocked {
                    ContentView()
                } else {
                    LineStylePasscodeView(isUnlocked: $isUnlocked)
                }
            }
        }
    }
}
