import Foundation
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    var captureSession = AVCaptureSession()
    private var movieOutput = AVCaptureMovieFileOutput()
    private var isRecording = false

    override init() {
        super.init()
    }

    func setupCamera(isFrontCamera: Bool) {
        let cameraPosition: AVCaptureDevice.Position = isFrontCamera ? .front : .back

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else {
            print("Error: No video capture device found")
            return
        }

        do {
            let captureInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.beginConfiguration()

            if captureSession.canAddInput(captureInput) {
                captureSession.addInput(captureInput)
                print("Camera input added successfully")
            } else {
                print("Error: Could not add camera input")
            }

            if captureSession.canAddOutput(movieOutput) {
                captureSession.addOutput(movieOutput)
                print("Movie output added successfully")
            } else {
                print("Error: Could not add movie output")
            }

            captureSession.commitConfiguration()

            // Start the capture session after all configurations
            captureSession.startRunning()
            print("Capture session started running")
        } catch {
            print("Error: Could not create capture input: \(error)")
        }
    }


    func startRecording(filename: String) {
        guard !isRecording else { return }

        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename).appendingPathExtension("mov")

        if movieOutput.isRecording {
            print("Already recording")
            return
        }

        movieOutput.startRecording(to: fileURL, recordingDelegate: self)
        isRecording = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.stopRecording()
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        movieOutput.stopRecording()
        isRecording = false
    }
}

extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo url: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error)")
        } else {
            print("Video saved to: \(url)")
        }
    }
}




