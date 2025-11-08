import Foundation

class ImageStorage {
    static let screenshotsFile = "screenshots.json"
    static let trashFile = "trash.json"
    
    // MARK: - 修正後の保存処理 (上書き保存)
    static func save(images: [ClassifiedImage], to fileName: String) {
        // 渡された配列が「最新の状態」であるため、既存ファイルとマージせず、そのまま全体を上書き保存します。
        
        // 1. 保存用に変換
        // ClassifiedImageがStorableImageに変換できる前提
        let storable = images.map { StorableImage(from: $0) }
        
        // 2. JSONにエンコード
        if let data = try? JSONEncoder().encode(storable) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            
            // 3. ファイルに書き込み (既存ファイルを上書き)
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                // 保存エラー発生時はコンソールに出力
                print("Error saving data to \(fileName): \(error)")
            }
        }
    }
    
    // 読み込み処理 (変更なし)
    static func load(from fileName: String) -> [ClassifiedImage] {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url),
              let stored = try? JSONDecoder().decode([StorableImage].self, from: data) else {
            return []
        }
        return stored.map { $0.toClassifiedImage() }
    }
    
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}


