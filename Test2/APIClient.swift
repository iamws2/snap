import Foundation
import SwiftUI

struct ChatResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

class APIClient: ObservableObject {
    private let apiKey: String = "api key" 
    private let chatGPTURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    

    func sendMessage(message: String, image: UIImage?, completion: @escaping (Result<String, Error>) -> Void) {
        var request = URLRequest(url: chatGPTURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var messages: [[String: Any]] = [
            ["role": "user", "content": [["type": "text", "text": message]]]
        ]
        
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64Image = imageData.base64EncodedString()
            messages[0]["content"] = [
                ["type": "text", "text": message],
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
            ]
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                let error = NSError(domain: "NetworkError", code: -1)
                completion(.failure(error))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                let content = decodedResponse.choices.first?.message.content ?? "コンテンツが見つかりませんでした。"
                completion(.success(content))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

