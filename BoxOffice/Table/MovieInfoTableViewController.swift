import UIKit

class MovieInfoTableViewController: UIViewController {

    // MARK:- IBOulet
    @IBOutlet var tableView: UITableView!
   
    // MARK:- Properties
    let cell = "movieInfoCell"
    var movieID: String = ""
    var movieInfo: MovieInfoResponse?
    var movieComments: [CommentsResponse.Comments]?
    let dateFormatter = DateFormatter()
    let full = "ic_star_large_full"
    let half = "ic_star_large_half"
    let empty = "ic_star_large"
    let movieSummerySection = 0
    let synopsisSection = 1
    let directorActorSection = 2
    let commentSection = 3
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MAKR:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidReceiveMoviesNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveCommentsNotification(_:)), name: DidReceiveCommentsNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveErrorNotification(_:)), name: DidReceiveErrorNotification, object: nil )
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        requestMovieInfo(id: movieID)
        requestComments(id: movieID)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK:- Function
    @objc func didReceiveCommentsNotification(_ noti: Notification) {
        guard let movieComments = noti.userInfo?["comments"] as? [CommentsResponse.Comments] else { return }
        self.movieComments =  movieComments
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    @objc func didReceiveMoviesNotification(_ noti: Notification) {
        guard let movieInfo = noti.userInfo?["movieinfo"] as? MovieInfoResponse else { return }
        self.movieInfo = movieInfo
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    @objc func didReceiveErrorNotification(_ noti: Notification) {
        DispatchQueue.main.async {
            self.showErrorAlertController(style: UIAlertControllerStyle.alert)
        }
    }
    
    func showErrorAlertController(style: UIAlertControllerStyle) {
        let alertController = UIAlertController(title: "알림", message: "데이터를 가져오지 못하였습니다", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: false, completion: nil)
    }
    
    func showUserRating(num: Int, reminder: Int, imageView: UIImageView, starOrder: Int) {
        if reminder == 0 {
            if num-1 >= starOrder {
                imageView.image = UIImage(named: full)
            } else {
                imageView.image = UIImage(named: empty)
            }
        } else if reminder == 1 {
            if num-1 >= starOrder {
                imageView.image = UIImage(named: full)
            } else if num == starOrder {
                imageView.image = UIImage(named: half)
            } else {
                imageView.image = UIImage(named: empty)
            }
        }
        
    }
    
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let movieInfo = self.movieInfo else { return }
        if segue.identifier == "showimage" {
            guard let desVC: PosterImageViewController = segue.destination as? PosterImageViewController else { return }
            desVC.url = movieInfo.image
        }
        if segue.identifier == "writecomment" {
            guard let desVC: WriteCommentViewController = segue.destination as? WriteCommentViewController else { return }
            desVC.movieId = movieInfo.id
            desVC.movieTitle = movieInfo.title
            desVC.movieGrade = movieInfo.grade
        }
    }
}

// MARK:- DataSource
extension MovieInfoTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == movieSummerySection {
            return 1
        } else if section == synopsisSection {
            return 1
        } else if section == directorActorSection {
            return 1
        } else if section == commentSection {
            return movieComments?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == movieSummerySection {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath) as? MovieInfoTableViewCell else { return UITableViewCell() }
            guard let movieInfo = self.movieInfo else { return UITableViewCell() }
            DispatchQueue.global().async {
                guard let imageURL: URL = URL(string: movieInfo.image) else { return }
                guard let imageData: Data = try? Data(contentsOf: imageURL) else { return }
                DispatchQueue.main.async {
                    cell.movieImageView.image = UIImage(data: imageData)
                }
            }
            cell.movieTitleLabel.text = movieInfo.title
            cell.movieDateLabel.text = movieInfo.datefull
            cell.movieGenreLabel.text = movieInfo.genreDurationFull
            cell.movieReservationRateLabel.text = movieInfo.reservationGradeReservationRateFull
            cell.userRateLabel.text = movieInfo.userRatinString
            cell.audienceLabel.text = movieInfo.audienceString
            cell.movieGradeImageView.image = UIImage.gradeImage(grade: movieInfo.grade)
            // 별점표시
            let num = Int(movieInfo.userRating) / 2
            let remainder = Int(movieInfo.userRating.truncatingRemainder(dividingBy: 2))
            for i in 0...4 {
                guard let imageView = cell.ratingStackView.arrangedSubviews[i] as? UIImageView else { return UITableViewCell() }
                showUserRating(num: num, reminder: remainder, imageView: imageView, starOrder: i)
            }
            return cell
        } else if indexPath.section == synopsisSection {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "synopsisCell", for: indexPath) as? SynopsisTableViewCell else { return UITableViewCell() }
            guard let movieInfo = self.movieInfo else { return UITableViewCell() }
            cell.synopsisLebel.text = movieInfo.synopsis
            return cell
        } else if indexPath.section == directorActorSection {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "directoractorCell", for: indexPath) as? DirectorActorTableViewCell else { return UITableViewCell() }
            guard let movieInfo = self.movieInfo else { return UITableViewCell() }
            cell.director.text = movieInfo.director
            cell.actor.text = movieInfo.actor
            return cell
        } else if indexPath.section == commentSection {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentscell", for: indexPath) as? CommentsTableViewCell else { return UITableViewCell() }
            guard let comments: CommentsResponse.Comments = self.movieComments?[indexPath.row] else { return UITableViewCell() }
            if indexPath.row == 0 {
                cell.commentTitleLabel.text = "한줄평"
                cell.writeButton.isHidden = false
                cell.contentsLabel.text = comments.contents
                cell.witerLabel.text = comments.writer
                let date = dateFormatter.string(from: Date(timeIntervalSince1970: comments.timestamp))
                cell.timestampLabel.text = date
                // 별점표시
                let num = Int(comments.rating) / 2
                let remainder = Int(comments.rating.truncatingRemainder(dividingBy: 2))
                for i in 0...4 {
                    guard let imageView = cell.ratingStackView.arrangedSubviews[i] as? UIImageView else { return UITableViewCell() }
                    showUserRating(num: num, reminder: remainder, imageView: imageView, starOrder: i)
                }
            } else {
                cell.commentTitleLabel.text = ""
                cell.writeButton.isHidden = true
                cell.contentsLabel.text = comments.contents
                cell.witerLabel.text = comments.writer
                let date = dateFormatter.string(from: Date(timeIntervalSince1970: comments.timestamp))
                cell.timestampLabel.text = date
                // 별점표시
                let num = Int(comments.rating) / 2
                let remainder = Int(comments.rating.truncatingRemainder(dividingBy: 2))
                for i in 0...4 {
                    guard let imageView = cell.ratingStackView.arrangedSubviews[i] as? UIImageView else { return UITableViewCell() }
                    showUserRating(num: num, reminder: remainder, imageView: imageView, starOrder: i)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        footerView.backgroundColor = UIColor.lightGray
        if section == movieSummerySection {
            return footerView
        } else if section == synopsisSection {
            return footerView
        } else if section == directorActorSection {
            return footerView
        }
        return nil
    }
}

// MARK:- Delegate
extension MovieInfoTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == movieSummerySection {
            return 200
        } else if indexPath.section == synopsisSection {
            return 450
        } else if indexPath.section == directorActorSection {
            return 130
        } else if indexPath.section == commentSection {
            return 150
        }
        return 100
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == movieSummerySection {
            return 7
        } else if section == synopsisSection {
            return 7
        } else if section == directorActorSection {
            return 7
        }
        return 0
    }
}













