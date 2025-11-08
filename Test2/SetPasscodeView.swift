import SwiftUI

// ピンク系のボタンスタイル定義
struct MyPinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 72, height: 72)
            .background(Color.pink.opacity(configuration.isPressed ? 0.4 : 0.5))
            .cornerRadius(36)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SetPasscodeView: View {
    @Binding var isUnlocked: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var input = [String?](repeating: nil, count: 4)
    @State private var error = ""
    
    var body: some View {
        ZStack {
            Color(hex: "#FAF3E5")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("新しいパスコードを設定してください")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.brown)
                    .lineLimit(1)       // 1行に制限
                    .minimumScaleFactor(0.5)
                
                HStack(spacing: 24) {
                    ForEach(0..<4) { index in
                        VStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(input[index] == nil ? Color.gray.opacity(0.3) : Color.pink)
                            
                            
                            
                        }
                    }
                }
                
                // エラー表示
                if !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .medium))
                        .transition(.opacity)
                }
                
                // 数字ボタン 0~9
                VStack(spacing: 16) {
                    ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                        HStack(spacing: 20) {
                            ForEach(row, id: \.self) { num in
                                Button(action: {
                                    appendNumber("\(num)")
                                }) {
                                    ZStack {
                                        // "bear"という名前の画像を使用
                                        Image("bear")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 72, height: 72)
                                           
                                        
                                        // 数字をクマの上にオーバーレイ
                                        Text("\(num)")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    HStack(spacing: 20) {
                        Spacer()
                        // 0のボタン
                        Button(action: {
                            appendNumber("0")
                        }) {
                            ZStack {
                                Image("bear")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 72, height: 72)
                                    
                                
                                Text("0")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                    // 削除ボタン
                    Button(action: {
                        deleteLast()
                    }) {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.pink.opacity(0.8))
                            .frame(width: 72, height: 72)
                            .background(
                                RoundedRectangle(cornerRadius: 36)
                                    .stroke(Color.pink, lineWidth: 2)
                                    .background(Color.white)
                                    .cornerRadius(36)
                            )
                            .shadow(color: Color.pink.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .cornerRadius(20)
            .shadow(color: Color.pink.opacity(0.15), radius: 10, x: 0, y: 5)
            .padding()
        }
    }
    
    private func appendNumber(_ num: String) {
        for i in 0..<input.count {
            if input[i] == nil {
                input[i] = num
                break
            }
        }
        checkInput()
    }
    
    private func deleteLast() {
        for i in (0..<input.count).reversed() {
            if input[i] != nil {
                input[i] = nil
                error = ""
                break
            }
        }
    }
    
    private func checkInput() {
        if input.allSatisfy({ $0 != nil }) {
            let newPasscode = input.compactMap{ $0 }.joined()
            if newPasscode.count == 4 {
                // 保存（KeychainHelperが別途必要です）
                KeychainHelper.shared.savePasscode(newPasscode)
                isUnlocked = true
                presentationMode.wrappedValue.dismiss()
            } else {
                error = "4桁のパスコードを入力してください"
                input = [String?](repeating: nil, count: 4)
            }
        }
    }
}


