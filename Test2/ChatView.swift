import SwiftUI

struct ChatView: View {
    var selectedImage: UIImage? = nil
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading: Bool = false
    
    @ObservedObject var apiClient: APIClient
    
    var body: some View {
        ZStack {
            Color(red: 250/255, green: 243/255, blue: 229/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .cornerRadius(12)
                        .padding()
                }
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            if message.isUser {
                                HStack {
                                    Spacer()
                                    Text(message.content)
                                        .padding(10)
                                        .background(Color.pink.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            } else {
                                HStack {
                                    Text(message.content)
                                        .padding(10)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(12)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if isLoading {
                    ProgressView("AIが考え中…")
                        .padding()
                }
                
                HStack {
                    TextField("メッセージを入力", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                    Button("送信") {
                        sendMessage()
                    }
                    .padding(.trailing)
                    .disabled(isLoading)
                }
            }
            .padding()
        }
        .navigationTitle("AIチャット")
    }
    
    // 💌 ChatGPTにメッセージ送信
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let userMessage = inputText
        messages.append(ChatMessage(content: userMessage, isUser: true))
        inputText = ""
        isLoading = true
        
        apiClient.sendMessage(message: userMessage, image: selectedImage) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    messages.append(ChatMessage(content: response, isUser: false))
                case .failure(let error):
                    messages.append(ChatMessage(content: "エラー: \(error.localizedDescription)", isUser: false))
                }
            }
        }
    }
}

