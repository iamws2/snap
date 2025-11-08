import SwiftUI

//画面部品
struct ImageListView: View {
    var title: String //カテゴリ名
    var images: [ClassifiedImage] //表示する画像のリスト
    
    var body: some View {
        ScrollView { //ScrollViewで画面を縦スクロールできる
            VStack(spacing: 16) {
                ForEach(images) { item in
                    Image(uiImage: item.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(title)
    }
}
