//
//  AIResultView.swift
//  Test2
//
//  Created by matsuoka shione on 2025/10/07.
//

import Foundation
import SwiftUI

struct AIResultView: View {
    @Binding var isPresented: Bool
    var image: ClassifiedImage?
    
    var body: some View {
        VStack {
            Text("AI相談結果")
                .font(.largeTitle)
                .padding()
            
            if let image = image {
                Text("画像 \(String(image.id.uuidString.prefix(4)))... の内容についてAIに相談します。").padding()
                
                // ここにAIへのAPI呼び出しや結果表示のロジックを実装します。
                // 例: ProgressView()またはText("AIが回答を生成中...")
                
            } else {
                Text("AI相談対象の画像がありません。")
            }
            
            Button("閉じる") {
                isPresented = false
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(40)
    }
}
