//
//  AIChatView.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/12/07.
//

import SwiftUI
import GoogleGenerativeAI

struct AIChatView: View {
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)

    @State var Prompt = ""
    @State var Respons = ""
    @State var isLoading = false

    var body: some View {
        ZStack {
            VStack {
                Text("Hello I am Gemini")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("何かお手伝いすることはありますか？")
                    .fontWeight(.bold)

                Spacer()

                ScrollView {
                    Text(Respons)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                HStack {

                    TextField("Aa", text: $Prompt)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()

                    Button(action: {
                        generateRespons()
                    }){
                        Image(systemName: "arrow.up")
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }.padding()
                }
            }

            if isLoading {
                Color.black.opacity(0.3)
                ProgressView()
            }
        }
    }

    func generateRespons() {
        isLoading = true
        Respons = ""

        Task {
            do {
                let result = try await model.generateContent(Prompt)
                isLoading = false
                Respons = result.text ?? "No Respons found"
                Prompt = ""
            } catch {
                Respons = "Sometimes went wrong \n \(error.localizedDescription)"
                isLoading = false
                Prompt = ""
            }
        }
    }
}

