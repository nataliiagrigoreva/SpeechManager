//
//  ContentView.swift
//  ContentView
//
//  Created by Nataly on 28.06.2023.
//

import SwiftUI
import Speech
import Combine

struct ContentView: View {
    @StateObject private var viewModel = SpeechRecognitionViewModel()
    
    var body: some View {
        VStack {
            Text("Распознавание речи")
                .font(.largeTitle)
            
            Text(viewModel.recognizedText)
                .padding()
                .onReceive(viewModel.$recognizedText) { text in
                    
                    print("Recognized text: \(text)")
                }
            
            Button(action: {
                if viewModel.isRecognitionActive {
                    viewModel.stopRecognition()
                } else {
                    viewModel.startRecognition()
                }
            }) {
                Text(viewModel.isRecognitionActive ? "Остановить" : "Старт")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
