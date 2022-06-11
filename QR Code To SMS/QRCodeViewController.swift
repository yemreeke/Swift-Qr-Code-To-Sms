import AVFoundation
import UIKit
import QRCodeReader
import MessageUI
class QRCodeViewController: UIViewController, QRCodeReaderViewControllerDelegate,MFMessageComposeViewControllerDelegate {
    var Kisi = Kisiler(isim: "", soyisim: "", numara: "")
    @IBOutlet weak var QrMetinLabel : UILabel!
    @IBOutlet weak var SmsButon : UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        QrMetinLabel.text=""
        SmsButon.isEnabled=false
        QRCodeTara()
    }
    
    @IBOutlet weak var previewView: QRCodeReaderView! {
        didSet {
            previewView.setupComponents(with: QRCodeReaderViewControllerBuilder {
            $0.reader                 = reader
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = false
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
            })
        }
    }
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
    let builder = QRCodeReaderViewControllerBuilder {
        $0.reader                  = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        $0.showTorchButton         = true
        $0.preferredStatusBarStyle = .lightContent
        $0.showOverlayView         = true
        $0.rectOfInterest          = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        $0.reader.stopScanningWhenCodeIsFound = false
    }
    return QRCodeReaderViewController(builder: builder)
  }()

  private func checkScanPermissions() -> Bool {
    do {
      return try QRCodeReader.supportsMetadataObjectTypes()
    } catch let error as NSError {
      let alert: UIAlertController
      switch error.code {
      case -11852:
        alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
          DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.openURL(settingsURL)
            }
          }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      default:
        alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      }
      present(alert, animated: true, completion: nil)
      return false
    }
  }

    @IBAction func QRCodeTara(){
        QrMetinLabel.text=""
        SmsButon.isEnabled=false
        guard checkScanPermissions(), !reader.isRunning else { return }
        reader.didFindCode = { result in
          print("Completion with result: \(result.value) of type \(result.metadataType)")
            self.QrMetinLabel.text = result.value
            self.SmsButon.isEnabled=true
        }
        reader.startScanning()
    }
  func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
    reader.stopScanning()

    dismiss(animated: true) { [weak self] in
      let alert = UIAlertController(
        title: "QRCodeReader",
        message: String (format:"%@ (of type %@)", result.value, result.metadataType),
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

      self?.present(alert, animated: true, completion: nil)
    }
  }
  func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
    print("Switching capture to: \(newCaptureDevice.device.localizedName)")
  }
  func readerDidCancel(_ reader: QRCodeReaderViewController) {
    reader.stopScanning()
    dismiss(animated: true, completion: nil)
  }
    @IBAction func SmsGonder(){
        let no = Kisi.numara
        let metin = QrMetinLabel.text!
        let messageVC = MFMessageComposeViewController()
        messageVC.body = metin;
        messageVC.recipients = [no]
        messageVC.messageComposeDelegate = self
        self.present(messageVC, animated: true, completion: nil)
    }
    func messageComposeViewController( _ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        var mesaj : String
        switch (result) {
            case .cancelled:
                mesaj = "SMS gönderme iptal edilmiştir."
            case .failed:
                mesaj = "SMS gönderilememiştir."
            case .sent:
                mesaj = "SMS gönderilmiştir."
            default:
                return
            }
        dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title:"SMS Durumu",message:mesaj,preferredStyle:.alert)
        let action = UIAlertAction(title: "TAMAM", style: .default, handler:nil)
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
}
