import SwiftUI
import Photos

// MARK: - ボタンのスタイル
struct PinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.pink.opacity(configuration.isPressed ? 0.4 : 0.5))
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - メインビュー
struct ContentView: View {
    @State private var screenshotImages: [ClassifiedImage] = []
    @State private var searchText: String = ""
    @State private var showSettings = false
    @AppStorage("isUnlocked") var isUnlocked = false
    @State private var groupedScreenshots: [String: [ClassifiedImage]] = [:]
    //重複チェック
    func removeDuplicateImages() {
        var seen = Set<String>()
        screenshotImages = screenshotImages.filter { image in
            guard let id = image.assetIdentifier else { return true }
            if seen.contains(id) {
                // 重複なので除外
                return false
            } else {
                seen.insert(id)
                return true
            }
        }
    }
    // MARK: - フィルタ済みリスト
    var filteredScreenshots: [ClassifiedImage] {
        if searchText.isEmpty { return screenshotImages }
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let keywordWithHash = keyword.hasPrefix("#") ? keyword : "#\(keyword)"
        return screenshotImages.filter { image in
            image.hashtags.contains { tag in
                tag.localizedCaseInsensitiveContains(keyword) ||
                tag.localizedCaseInsensitiveContains(keywordWithHash)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 250/255, green: 243/255, blue: 229/255)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Snap Memory")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    
                    //検索バー
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.brown)
                        TextField("検索ワードを入力", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 10)
                    }
                    .padding(.horizontal, 20)
                    
                    //初回ボタン
                    if screenshotImages.isEmpty {
                        Button("PNGスクリーンショットを分類する") {
                            checkPermissionsAndFetchScreenshots()
                        }
                        .buttonStyle(PinkButtonStyle())
                        .padding(.horizontal, 20)
                    }
                    
                    //画像リスト
                    if !screenshotImages.isEmpty {
                        if searchText.isEmpty {
                            List {
                                ForEach(groupedScreenshots.keys.sorted(), id: \.self) { category in
                                    NavigationLink(
                                        destination: ScreenshotListView(
                                            title: category,
                                            images: $screenshotImages,
                                            filter: { $0.result == category }
                                        )
                                    ) {
                                        HStack {
                                            Image(systemName: "folder.fill")
                                                .foregroundColor(.brown)
                                            Text("\(category)（\(groupedScreenshots[category]?.count ?? 0)枚）")
                                                .font(.headline)
                                                .foregroundColor(.brown)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(15)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .listStyle(PlainListStyle())
                        } else {
                            ScreenshotListView(
                                title: "検索結果",
                                images: $screenshotImages,
                                filter: { img in
                                    img.hashtags.contains {
                                        $0.lowercased().contains(
                                            searchText.lowercased().replacingOccurrences(of: "#", with: "")
                                        )
                                    }
                                }
                            )
                        }
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape")
                                .foregroundColor(.brown)
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    NavigationStack {
                        SettingsView(isUnlocked: $isUnlocked)
                    }
                }
                .onAppear {
                    //画像の読み込みと分類
                    screenshotImages = ImageStorage.load(from: ImageStorage.screenshotsFile)
                    groupedScreenshots = Dictionary(grouping: screenshotImages, by: { $0.result })

                    //通知権限を確認
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                        if granted {
                            print("通知許可されました")
                        } else {
                            print("通知が許可されませんでした")
                        }
                    }
                }

                .onChange(of: screenshotImages) { newValue in
                    ImageStorage.save(images: newValue, to: ImageStorage.screenshotsFile)
                    groupedScreenshots = Dictionary(grouping: newValue, by: { $0.result })
                }
                
                //リロードボタン
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            checkPermissionsAndFetchScreenshots {
                                reclassifyUnclassifiedImages()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color.pink.opacity(0.6))
                                .padding(20)
                        }

                    }
                }
            }
        }
        .tint(.brown)
    }
    
    // MARK: - 写真ライブラリ、通知許可チェック


    func checkPermissionsAndFetchScreenshots(completion: @escaping () -> Void = {}) {
        PHPhotoLibrary.requestAuthorization { photoStatus in
            if photoStatus == .authorized || photoStatus == .limited {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                    DispatchQueue.main.async {
                        if granted {
                            print("通知許可されました")
                        } else {
                            print("通知が許可されませんでした")
                        }
                        fetchPngScreenshots {
                            completion()
                        }
                    }
                }
            } else {
                print("写真へのアクセスが拒否されました")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }


    //MARK: - 新規スクショのみ取得＆分類
    func fetchPngScreenshots(completion: @escaping () -> Void = {}) {
        print("🔍 スクリーンショット取得開始")
        
        let existingIDs = Set(screenshotImages.compactMap { $0.assetIdentifier })
        // ここでログを出す
        print("Existing asset IDs: \(existingIDs)")
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        var newImages: [ClassifiedImage] = []
        let group = DispatchGroup()
        
        assets.enumerateObjects { asset, _, _ in
            if let filename = asset.value(forKey: "filename") as? String,
               filename.lowercased().hasSuffix(".png"),
               !existingIDs.contains(asset.localIdentifier) {
                // 新しく検出した asset のログ
                 print("New asset detected: \(asset.localIdentifier)")
                let targetSize = CGSize(width: 512, height: 512)
                group.enter()
                
                imageManager.requestImage(for: asset,
                                          targetSize: targetSize,
                                          contentMode: .aspectFit,
                                          options: requestOptions) { image, _ in
                    if let image = image {
                        let newItem = ClassifiedImage(
                            image: image,
                            result: "未分類",
                            hashtags: [],
                            filename: filename,
                            assetIdentifier: asset.localIdentifier
                        )
                        newImages.append(newItem)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if newImages.isEmpty {
                print("🟡 新しいPNGスクリーンショットは見つかりませんでした。")
                completion()
                return
            }
            
            print("🆕 新しい画像 \(newImages.count) 枚を分類します。")
            
            self.screenshotImages.append(contentsOf: newImages)
            removeDuplicateImages()
            for (index, newImage) in newImages.enumerated() {
                let currentImageIndex = self.screenshotImages.count - newImages.count + index
                self.classifyScreenshotImage(image: newImage.image, index: currentImageIndex)
                self.fetchHashtags(image: newImage.image, index: currentImageIndex)
            }
            
            completion()
        }
    }

    // MARK: - 未分類の画像を再分類する新しい関数
    func reclassifyUnclassifiedImages() {
        print("🔄 未分類の画像を再分類します。")
        for (index, image) in screenshotImages.enumerated() {
            if image.result == "未分類" {
                self.classifyScreenshotImage(image: image.image, index: index)
                self.fetchHashtags(image: image.image, index: index)
            }
        }
    }
    
    // MARK: - ChatGPT分類
    func classifyScreenshotImage(image: UIImage, index: Int) {
        guard let base64Image = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else { return }
        let apiKey = "api key"
        
        let json: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "この画像は必ず次のいずれかに分類してください：風景,食べ物,時刻表,人物,洋服,音楽,書類,レシピ,ゲーム,その他。1つだけ選んで正確に返してください。"],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 50
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let body = try? JSONSerialization.data(withJSONObject: json) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            var resultText = "未分類"
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                resultText = content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            DispatchQueue.main.async {
                if index < screenshotImages.count {
                    screenshotImages[index].result = resultText
                }
            }
        }.resume()
    }
    
    // MARK: - ハッシュタグ生成 (変更なし)
    func fetchHashtags(image: UIImage, index: Int) {
        guard let base64Image = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else { return }
        let apiKey = "api key"
        
        let json: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "この画像に関連するハッシュタグを3つ教えてください。#をつけて半角スペースで区切って返してください。もし分からなければ、何も出力しないでください。"],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 50
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let body = try? JSONSerialization.data(withJSONObject: json) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            var hashtags: [String] = []
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                hashtags = content
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: " ")
            }
            
            DispatchQueue.main.async {
                if index < screenshotImages.count {
                    screenshotImages[index].hashtags = hashtags
                }
            }
        }.resume()
    }
}
