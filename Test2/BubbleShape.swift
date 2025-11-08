//
//  BubbleShape.swift
//  Test2
//
//  Created by matsuoka shione on 2025/10/07.
//

import Foundation
import SwiftUI

// メッセージを管理するための構造体
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool // trueならユーザー、falseならAI
}

// 吹き出しの形を定義するShape
struct BubbleShape: Shape {
    var isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: isUser ? [.topLeft, .bottomLeft, .bottomRight] : [.topRight, .bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 15, height: 15))
        return Path(path.cgPath)
    }
}
