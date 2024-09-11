import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var input = "" // For the text field
    @State private var isRecording = false

    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true) // Camera access granted
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false) // Camera access denied
        @unknown default:
            completion(false)
        }
    }

    var body: some View {
        VStack {
            // Input field and button section
            VStack {
                HStack {
                    Text("Video Name:")
                    TextField("Enter video name", text: $input)
                }
                Button(action: {
                    if isRecording {
                        cameraViewModel.stopRecording()
                    } else {
                        let filename = "video_\(Date().timeIntervalSince1970)"
                        cameraViewModel.startRecording(filename: filename)
                    }
                    isRecording.toggle()
                }) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)

                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            CameraPreview(cameraViewModel: cameraViewModel)
                .frame(height: 300)
                .cornerRadius(10)
                .border(Color.gray) // Optional: Adds a border to see the preview's bounds
                .onAppear {
                            cameraViewModel.setupCamera(isFrontCamera: true) // Or true for front camera
                        }
            /*
            // Camera preview section
            CameraPreview(cameraViewModel: cameraViewModel)
                .frame(height: 300)
                .cornerRadius(10)
                .border(Color.gray) // Optional: Adds a border to see the preview's bounds
*/
            Spacer() // Push the camera preview to the top
        }
        .padding()
        .onAppear {
            checkCameraPermission { granted in
                if granted {
                    cameraViewModel.setupCamera(isFrontCamera: true)
                    print("Camera setup complete")
                } else {
                    print("No camera access")
                }
            }
        }
        .onDisappear {
            cameraViewModel.stopRecording()
        }
    }
}
