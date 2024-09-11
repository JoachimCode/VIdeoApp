import Foundation
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    var captureSession = AVCaptureSession()
    var videoOutput = AVCaptureVideoDataOutput()

    func setupCamera(isFrontCamera: Bool) {
        
        // Select the correct camera
        let cameraPosition: AVCaptureDevice.Position = isFrontCamera ? .front : .back
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else {
            print("Error: No video capture device found")
            return
        }

        do {
            // Add input from the camera
            let captureInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.beginConfiguration() // Start configuring session
            
            if captureSession.canAddInput(captureInput) {
                captureSession.addInput(captureInput)
            } else {
                print("Error: Could not add capture input")
                return
            }
            
            // Configure video output if needed (optional for preview only)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            } else {
                print("Error: Could not add video output")
                return
            }

            captureSession.commitConfiguration() // Commit session setup
            captureSession.startRunning()

        } catch {
            print("Error: Could not create capture input: \(error)")
            return
        }
    }

    func stopCamera() {
        captureSession.stopRunning()
    }
}

// Conform to AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Handle the video frame processing here
    }
}
