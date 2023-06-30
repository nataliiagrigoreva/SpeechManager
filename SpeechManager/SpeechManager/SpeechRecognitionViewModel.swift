//
//  SpeechRecognitionViewModel.swift
//  SpeechRecognitionViewModel
//
//  Created by Nataly on 28.06.2023.
//

import SwiftUI
import Speech
import Combine

class SpeechRecognitionViewModel: ObservableObject {
    @Published var recognizedText = ""
    @Published var isRecognitionActive = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU")) // Используем русский язык для распознавания речи
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var cancellables = Set<AnyCancellable>()
    
    func startRecognition() {
        _ = audioEngine.inputNode
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
                guard let self = self else { return }
                
                if let result = result {
                    let recognizedString = result.bestTranscription.formattedString
                    let randomNumber = Int.random(in: 0...100)
                    DispatchQueue.main.async {
                        self.recognizedText = "\(recognizedString) \(randomNumber)"
                    }
                } else if let error = error {
                    print("Recognition task error: \(error)")
                }
            })
            
            _ = recordingFormat.formatDescription
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecognitionActive = true
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    func stopRecognition() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        isRecognitionActive = false
    }
}
