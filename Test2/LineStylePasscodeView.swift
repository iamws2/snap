import SwiftUI

struct LineStylePasscodeView: View {
    @Binding var isUnlocked: Bool
    @State private var input = [String?](repeating: nil, count: 4)
    @State private var error = ""
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 243/255, blue: 229/255)
                 .ignoresSafeArea()

            
            VStack(spacing: 40) {
                Text("パスコードを入力してください")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.brown)
                
                // 入力状況の表示
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
        checkPasscode()
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
    
    private func checkPasscode() {
        if input.allSatisfy({ $0 != nil }) {
            let entered = input.compactMap{ $0 }.joined()
            let savedPasscode = KeychainHelper.shared.getPasscode() ?? "1234"
            if entered == savedPasscode {
                isUnlocked = true
            } else {
                error = "パスコードが違います"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    input = [String?](repeating: nil, count: 4)
                }
            }
        }
    }
}

// Colorの拡張で16進カラーを扱いやすく
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // #をスキップ
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}

