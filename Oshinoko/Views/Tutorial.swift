import SwiftUI

struct Tutorial: View {
    @State private var isOverlayVisible: Bool = true // TutorialOverlayの表示状態を管理

    var body: some View {
        ZStack {
            // メインのTutorial内容
            Text("Hello, World!")
                .font(.largeTitle)
                .padding()

            // オーバーレイ
            if isOverlayVisible {
                TutorialOverlayView(isVisible: $isOverlayVisible)
            }
        }
    }
}

struct TutorialOverlayView: View {
    @State private var tapCount: Int = 0
    @Binding var isVisible: Bool // 表示状態を管理

    let maxTaps: Int = 3 // タップ回数の上限

    private let messages = [
        "ねぇねぇ！地図の空いてる場所を長押ししてみて！ピンが立てられるんだよ！共有もできちゃう！",
        "ほら、地図にあるアイコンをタップしてみて！観光地やみんなのコメントが見れるよ！",
        "さぁ、君もおすすめのスポットにピンを立てて、みんなに教えてあげよう！"
    ]
    
    private let images = [
        "Map_tutorial1",
        "Map_Tutorial3",
        "Detail_Tutorail",
    ]

    var body: some View {
        ZStack {
            // 透明な背景
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    handleTap()
                }

            // メッセージ表示
            if tapCount < messages.count {
                
                Rectangle()
                    .frame(width: 325,height:675)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    
                    .padding()
                VStack{
                    ZStack{
                        Image(images[tapCount])
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(25)
                        
                        if (tapCount < 2){
                            HoldAnimationView(lottieFile: "hold")
                                .frame(width:100 , height: 100)
                                .offset(x: -30,y:20)
                        }
                        
                        
                        Text(messages[tapCount])
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                            .padding()
                            .offset(y: -150)
                        
                    }
                    .frame(width:300,height:600)
                    .padding()
                    
                    if(tapCount == 0) {
                        Text("⚫︎  ⚪︎  ⚪︎")
                    } else if (tapCount == 1) {
                        Text("⚪︎  ⚫︎  ⚪︎")
                    } else {
                        Text("⚪︎  ⚪︎  ⚫︎")
                    }
                }
            }
        }
        .opacity(isVisible ? 1 : 0) // 表示状態に応じて透明度を変更
        .animation(.easeInOut, value: isVisible) // アニメーション
        .transition(.opacity) // フェードイン・アウトのトランジション
    }

    private func handleTap() {
        tapCount += 1
        if tapCount >= maxTaps {
            withAnimation {
                isVisible = false // 非表示にする
                saveTutorialSeenFlag() // 表示済みフラグを設定
            }
        }
    }

    private func saveTutorialSeenFlag() {
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
    }
}

#Preview {
    Tutorial()
}
