import UIKit

class PosterImageViewController: UIViewController {

    // MARK:- IBOulet
    @IBOutlet var posterImageView: UIImageView!
    
    // MARK:- Properties
    var url: String?
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global().async {
            guard let url = self.url else { return }
            guard let imageURL: URL = URL(string: url) else { return }
            guard let imageData: Data = try? Data(contentsOf: imageURL) else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    // MARK:- IBAction
    @IBAction func touchUpDismissModalButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }    
}
