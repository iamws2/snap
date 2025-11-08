import SwiftUI

struct TrashListView: View {
    @Binding var trashImages: [ClassifiedImage]
    @Binding var images: [ClassifiedImage]

    var body: some View {
        List {
            ForEach(trashImages) { item in
                HStack {
                    Image(uiImage: item.image)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                    Text(item.result)
                    Spacer()
                    Button("復元") {
                        if let index = trashImages.firstIndex(where: { $0.id == item.id }) {
                            let restored = trashImages.remove(at: index)
                            images.append(restored)
                            
                            // 保存追加
                            ImageStorage.save(images: images, to: ImageStorage.screenshotsFile)
      
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .onDelete { indexSet in
                trashImages.remove(atOffsets: indexSet) // 完全削除
                ImageStorage.save(images: trashImages,to:ImageStorage.trashFile)
            }
        }
        .navigationTitle("ゴミ箱")
        .toolbar {
            EditButton()
        }
    }
}
