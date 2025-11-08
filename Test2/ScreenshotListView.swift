import SwiftUI

// スクリーンショット一覧
struct ScreenshotListView: View {
    var title: String
    @Binding var images: [ClassifiedImage]
    // @Binding var trashImages: [ClassifiedImage] // 削除
    @State private var showAIResult = false
    var filter: ((ClassifiedImage) -> Bool)? = nil    //絞り込みのため
    // TagNotificationManager のインスタンスを用意
    func checkNotifications() {
        let manager = TagNotificationManager(images: images)
        manager.checkAndNotifyTagRecommendations()
    }

    // 3列グリッド
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    // 選択中の画像
    @State private var selectedImage: ClassifiedImage? = nil
    @State private var showOverlay = false
    
    // タグ追加用
    @State private var showAddTag = false
    @State private var newTag = ""
    
    //編集モード用
    @State private var isEditing = false
    // 選択中の画像のインデックス（IDではなく配列の位置）
    @State private var selectedImageIndex: Int? = nil
    // リマインダー設定用フラグ（表示制御用）
    //@State private var showReminderPicker = false
    //カテゴリ移動、新規カテゴリ作成用
    @State private var showCategoryInput = false
    @State private var newCategoryName = ""
    @State private var previousCategory = ""
    // MARK: - 画像をリストから完全に削除し保存
    func deleteImage(at index: Int) {
        withAnimation {
            // リストから画像を削除する
            _ = images.remove(at: index)
            
            // 削除後、すぐに保存処理を実行
            // trashImagesを扱わないため、screenshotsFileのみを更新すればよい
            ImageStorage.save(images: images, to: ImageStorage.screenshotsFile)
        }
    }
    
    // フィルタ済みリスト
    private var displayedImages: [ClassifiedImage] {
        if let filter = filter {
            return images.filter(filter)
        } else {
            return images
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 243/255, blue: 229/255)
                .edgesIgnoringSafeArea(.all)
            // グリッド表示
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(displayedImages) { item in
                        VStack(spacing: 6) {
                            Image(uiImage: item.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipped()
                                .cornerRadius(10)
                                .onTapGesture {
                                    if !isEditing {
                                        // 画像のインデックスを取得して記憶
                                        if let idx = images.firstIndex(where: { $0.id == item.id }) {
                                            selectedImageIndex = idx
                                            selectedImage = images[idx]
                                            withAnimation(.spring()) {
                                                showOverlay = true
                                            }
                                        }
                                    }
                                }

                            
                            if isEditing {
                                Button(action: {
                                    if let indexInImages = images.firstIndex(where: { $0.id == item.id }) {
                                        // 修正: 完全に削除するメソッドを呼び出す
                                        deleteImage(at: indexInImages)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle(title)
            //編集ボタン
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "完了" : "編集") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
            }
            .tint(.brown)
            .padding()
            
            
            // オーバーレイ表示
            if showOverlay, let selectedIndex = selectedImageIndex {
                let selectedImage = images[selectedIndex]

                VStack {
                    Image(uiImage: selectedImage.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 350, maxHeight: 450)
                        .cornerRadius(16)
                        .shadow(radius: 20)
                        .padding(15)

                    VStack(alignment: .leading, spacing: 10) {
                        // ハッシュタグ表示
                        if !selectedImage.hashtags.isEmpty {
                            Text(selectedImage.hashtags.joined(separator: " "))
                                .font(.footnote)
                                .foregroundColor(.brown)
                        }
                        // AI相談ボタン（変えなくてOK）
                        NavigationLink(
                            destination: ChatView(selectedImage: selectedImage.image, apiClient: APIClient())
                        ) {
                            HStack(spacing: 8) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.headline)
                                Text("AIに相談する")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        Divider()
                            .padding(.vertical, 8)

                        // カテゴリ移動セクション
                        Text("カテゴリを変更")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.brown)

                            Picker("カテゴリを選択", selection: Binding(
                                get: { images[selectedIndex].result },
                                set: { newValue in
                                    previousCategory = images[selectedIndex].result // ← 変更前を保存
                                    images[selectedIndex].result = newValue
                                    ImageStorage.save(images: images, to: ImageStorage.screenshotsFile)
                                }
                            )) {
                                ForEach(Array(Set(images.map { $0.result })), id: \.self) { category in
                                    Text(category).tag(category)
                                }
                                Text("＋ 新しいカテゴリを作成").tag("＋ 新しいカテゴリを作成")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(.brown)
                            .padding(.vertical, 4)
                            .onChange(of: images[selectedIndex].result) { newValue in
                                if newValue == "＋ 新しいカテゴリを作成" {
                                    showCategoryInput = true
                                }
                            }
                            .alert("新しいカテゴリを作成", isPresented: $showCategoryInput) {
                                TextField("カテゴリ名を入力", text: $newCategoryName)
                                Button("追加") {
                                    if !newCategoryName.isEmpty {
                                        images[selectedIndex].result = newCategoryName
                                        ImageStorage.save(images: images, to: ImageStorage.screenshotsFile)
                                    } else {
                                        images[selectedIndex].result = previousCategory
                                    }
                                    newCategoryName = ""
                                }
                                Button("キャンセル", role: .cancel) {
                                    // 👇キャンセル時に元のカテゴリに戻す
                                    images[selectedIndex].result = previousCategory
                                }
                            } message: {
                                Text("この画像を新しいカテゴリに移動します。")
                            }


                        /*// リマインダー設定ボタン
                        Button(action: {
                            withAnimation {
                                showReminderPicker = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "alarm.fill")
                                    .font(.headline)
                                Text(selectedImage.reminderSet ? "リマインダー設定済み" : "リマインダーを設定")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedImage.reminderSet ? Color.mint.opacity(0.8) : Color.mint.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }


                      ReminderView(
                            isPresented: $showReminderPicker,
                            reminderSet: Binding<Bool>(
                                get: { images[selectedIndex].reminderSet },
                                set: { _ in /* 空でOK */ }
                            ),
                            setDate: Binding<Date?>(
                                get: { images[selectedIndex].reminderDate },
                                set: { newDate in
                                    images[selectedIndex].reminderDate = newDate

                                    if let date = newDate {
                                        images[selectedIndex].scheduleNotification()  // 通知を登録
                                    } else {
                                        images[selectedIndex].cancelNotification()    // 通知をキャンセル
                                    }

                                    ImageStorage.save(images: images, to: ImageStorage.screenshotsFile)  // 保存
                                }
                            )
                        )*/

                    }
                    .padding()
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 20)
                )
                .padding(.horizontal, 20)

                // ✕ボタン
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring()) {
                                showOverlay = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.brown)
                                .padding()
                        }
                    }
                    Spacer()
                }
                .offset(y: -15)

                // 右下タグ追加ボタン（必要なら変えなくてOK）
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // selectedImage設定の部分を一旦コメントアウト
                            /*
                            if selectedImage == nil {
                                if let selectedIndex = selectedImageIndex {
                                    selectedImage = images[selectedIndex]
                                }
                            }
                            */
                            withAnimation {
                                showAddTag = true
                            }
                        } label: {
                            Image(systemName: "plus.square.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(Color.pink.opacity(0.6))
                                .padding()
                        }


                    }
                }
                .offset(x: -20,y: -5)
            }


            // タグ追加ビュー
            if showAddTag, let selected = selectedImage, let index = images.firstIndex(where: { $0.id == selected.id }) {
                AddTagOverlay(tagText: $newTag) { tag in
                    // タグを追加
                    if !tag.isEmpty {
                        images[index].hashtags.append(tag)
                        selectedImage = images[index]
                    }
                    newTag = ""
                    showAddTag = false
                }onCancel: {
                    newTag = ""
                    showAddTag = false
                }
                .zIndex(5) // ← 最前面に出す！
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            checkNotifications()
        }
    }
}


// タグ追加オーバーレイ (変更なし)
struct AddTagOverlay: View {
    @Binding var tagText: String
    var onAdd: (String) -> Void
    var onCancel: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                // TextField
                TextField("タグを入力してください", text: $tagText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // 追加とキャンセルを横並び
                HStack(spacing: 12) {
                    Button("追加") {
                        let tagWithHash = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !tagWithHash.isEmpty {
                            let finalTag = tagWithHash.hasPrefix("#") ? tagWithHash : "#" + tagWithHash
                            onAdd(finalTag)
                        }
                        tagText = ""
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.pink.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("キャンセル") {
                        tagText = ""
                        onCancel?()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.brown)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding()
        }
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel?()
                }
        )
    }
}
