import SwiftUI
struct PasscodeView: View {
    @Binding var isUnlocked: Bool
    @State private var input = ""
    @State private var error = ""
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 243/255, blue: 229/255)
                .ignoresSafeArea()
        VStack(spacing: 20) {

                Text("パスコードを入力してください")
                    .font(.headline)
                
                SecureField("パスコード", text: $input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 200)
                
                Button("解除") {
                    let savedPasscode = KeychainHelper.shared.getPasscode() ?? "1234"
                    
                    if input == savedPasscode {
                        isUnlocked = true
                    } else {
                        error = "パスコードが違います"
                    }
                }
                
                if !error.isEmpty {
                    Text(error).foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}
