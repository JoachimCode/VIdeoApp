import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var input = "" // For the text field
    
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
                Button("Record") {
                    // Add recording logic here (e.g., save videoName, start recording)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            // Camera preview section
            CameraPreview(cameraViewModel: cameraViewModel)
                .frame(height: 300)
                .cornerRadius(10)

            Spacer() // Push the camera preview to the top
        }
        .padding()
        .onAppear {
            checkCameraPermission { granted in
                if granted {
                    cameraViewModel.setupCamera(isFrontCamera: true)
                    print("Flag1")
                }
                else {
                    print("No access")
                }
            }
        }
        .onDisappear {
            cameraViewModel.stopCamera()
        }
    }
}

// ... (Rest of your code, including CameraViewModel and CameraPreview)
