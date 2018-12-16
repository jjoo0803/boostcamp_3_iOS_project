import UIKit

class WriteCommentViewController: UIViewController {

    // MARK:- IBOulet
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var movieGradeImageView: UIImageView!
    @IBOutlet var starImageView1: UIImageView!
    @IBOutlet var starImageView2: UIImageView!
    @IBOutlet var starImageView3: UIImageView!
    @IBOutlet var starImageView4: UIImageView!
    @IBOutlet var starImageView5: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var writerTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var starStackView: UIStackView!
    
    // MARK:- Properties
    let full = "ic_star_large_full"
    let half = "ic_star_large_half"
    let empty = "ic_star_large"
    var movieId: String?
    var number = 0
    var movieTitle: String?
    var movieGrade: Int?
    var rating = 10.0
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 5.0
        contentTextView.layer.borderColor = UIColor.red.cgColor
        writerTextField.text = ""
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(draggingStar))
        starStackView.addGestureRecognizer(gesture)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentTextView.text = "한줄평을 작성해주세요"
        contentTextView.textColor = UIColor.lightGray
        writerTextField.text = UserInformation.shared.nickname
        movieTitleLabel.text = movieTitle
        guard let movieGrade = self.movieGrade else { return}
        movieGradeImageView.image =  UIImage.gradeImage(grade: movieGrade)
    }
    
    // MARK:- Function
    @objc func draggingStar(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: view)
        setRating(float: point)
    }
    
    func setRating(float: CGPoint) {
        let value = Int(float.x / 24) - 2
        if value >= 0 && value <= 10 {
            self.ratingLabel.text = String(value) // 0 ~ 10
            self.rating = Double(value)
        }
        let remainder = (value % 2)
        if remainder == 1 {
            for i in 0...4 {
                guard let imageView = starStackView.arrangedSubviews[i] as? UIImageView else { return }
                if value/2 > i {
                    imageView.image = UIImage(named: full)
                } else if value/2 == i {
                    imageView.image = UIImage(named: half)
                } else {
                    imageView.image = UIImage(named: empty)
                }
            }
        } else if remainder == 0{
            for i in 0...4 {
                guard let imageView = starStackView.arrangedSubviews[i] as? UIImageView else { return }
                if value/2 > i {
                    imageView.image = UIImage(named: full)
                } else {
                    imageView.image = UIImage(named: empty)
                }
            }
        }
    }
    
    func showAlertController(style: UIAlertControllerStyle) {
        let alertController = UIAlertController(title: "경고", message: "빈 칸을 모두 작성해주세요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: false, completion: nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activityIndicator.stopAnimating()
    }
    
    
    // MARK:- IBAction
    @IBAction func touchUpCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchUpFinishButton(_ sender: UIBarButtonItem) {
        if writerTextField.text == "" || contentTextView.text == "" || contentTextView.text == "한줄평을 작성해주세요" {
             self.showAlertController(style: UIAlertControllerStyle.alert)
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.activityIndicator.startAnimating()
            print("start")
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            let content = EncodingModel(movieId: self.movieId, rating: rating, contents: self.contentTextView.text, writer: self.writerTextField.text)
            let jsonData = try? encoder.encode(content)
            if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                guard let movieId = self.movieId else { return }
                postAction(movieId: movieId, rating: rating, contents: self.contentTextView.text, writer: self.writerTextField.text ?? "")
                self.dismiss(animated: true, completion: nil)
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }
        }
        if writerTextField.text != "" {
            UserInformation.shared.nickname = writerTextField.text
        }
    }
    
    @IBAction func tapView (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

// MARK:- Delegate
extension WriteCommentViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "한줄평을 작성해주세요"
            textView.textColor = UIColor.lightGray
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "한줄평을 작성해주세요" {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
}


