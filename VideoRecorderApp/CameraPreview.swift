import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let cameraViewModel: CameraViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraViewModel.captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds

        view.layer.addSublayer(previewLayer)

        // Make sure the capture session starts running
        if !cameraViewModel.captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.cameraViewModel.captureSession.startRunning()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds // Ensure preview layer fits the view
            }
        }
    }
}
