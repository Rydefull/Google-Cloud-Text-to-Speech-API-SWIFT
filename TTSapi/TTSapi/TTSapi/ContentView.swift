import SwiftUI
import Alamofire
import AVFoundation

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var isSpeaking: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var selectedLanguage: String = "en-US"
    @State private var selectedGender: String = "FEMALE"
    @State private var selectedVoiceType: String = "Standard"
    
    let apiKey = "YOURAPI" // Замените на ваш API ключ
    let languages = ["en-US", "ru-RU"]
    let genders = ["FEMALE", "MALE"]
    let voiceTypes = ["Standard", "WaveNet"]
    
    var body: some View {
        VStack {
            Text("Enter text to speak")
                .font(.title)
                .padding()
            
            TextEditor(text: $inputText)
                .padding()
                .border(Color.gray, width: 1)
            
            Picker("Select Language", selection: $selectedLanguage) {
                ForEach(languages, id: \.self) { language in
                    Text(language)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Picker("Select Gender", selection: $selectedGender) {
                ForEach(genders, id: \.self) { gender in
                    Text(gender)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Picker("Select Voice Type", selection: $selectedVoiceType) {
                ForEach(voiceTypes, id: \.self) { voiceType in
                    Text(voiceType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                Button(action: {
                    self.textToSpeech(text: self.inputText)
                }) {
                    Text(isSpeaking ? "Speaking..." : "Speak")
                        .foregroundColor(.white)
                        .padding()
                        .background(isSpeaking ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(isSpeaking)
                
                Button(action: {
                    self.stopSpeaking()
                }) {
                    Text("Stop")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .padding()
    }
    
    func textToSpeech(text: String) {
        guard !text.isEmpty else { return }
        isSpeaking = true
        
        let voiceName: String
        switch (selectedLanguage, selectedGender, selectedVoiceType) {
        case ("en-US", "FEMALE", "WaveNet"):
            voiceName = "en-US-Wavenet-F"
        case ("en-US", "MALE", "WaveNet"):
            voiceName = "en-US-Wavenet-D"
        case ("ru-RU", "FEMALE", "WaveNet"):
            voiceName = "ru-RU-Wavenet-C"
        case ("ru-RU", "MALE", "WaveNet"):
            voiceName = "ru-RU-Wavenet-B"
        case ("en-US", "FEMALE", "Standard"):
            voiceName = "en-US-Standard-F"
        case ("en-US", "MALE", "Standard"):
            voiceName = "en-US-Standard-D"
        case ("ru-RU", "FEMALE", "Standard"):
            voiceName = "ru-RU-Standard-C"
        case ("ru-RU", "MALE", "Standard"):
            voiceName = "ru-RU-Standard-B"
        default:
            voiceName = "\(selectedLanguage)-Standard-D"
        }
        
        let url = "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(apiKey)"
        
        let parameters: [String: Any] = [
            "input": [
                "text": text
            ],
            "voice": [
                "languageCode": selectedLanguage,
                "name": voiceName,
                "ssmlGender": selectedGender
            ],
            "audioConfig": [
                "audioEncoding": "MP3"
            ]
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any],
                           let audioContent = json["audioContent"] as? String,
                           let audioData = Data(base64Encoded: audioContent) {
                            self.playAudio(audioData: audioData)
                        } else {
                            print("Invalid response format")
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                    self.isSpeaking = false
                }
            }
            
            func playAudio(audioData: Data) {
                do {
                    audioPlayer = try AVAudioPlayer(data: audioData)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                } catch {
                    print("Error playing audio: \(error)")
                }
            }
            
            func stopSpeaking() {
                audioPlayer?.stop()
                isSpeaking = false
            }
        }

        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
