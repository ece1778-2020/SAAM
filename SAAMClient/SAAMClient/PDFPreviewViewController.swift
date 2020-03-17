import UIKit
import PDFKit

class PDFPreviewViewController: UIViewController {
  public var documentData: Data?
  @IBOutlet weak var pdfView: PDFView!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pdfView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    
    if let data = documentData {
      pdfView.document = PDFDocument(data: data)
      pdfView.autoScales = true
    }
  }
    
    @IBAction func Print(_ sender: UIButton) {


        let vc = UIActivityViewController(activityItems: [documentData], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func BackTapped(_ sender: Any) {
        performSegue(withIdentifier: "pdfBackProfile", sender: self)
    }
    
}
