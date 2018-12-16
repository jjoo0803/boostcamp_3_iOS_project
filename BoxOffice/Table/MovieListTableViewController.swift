import UIKit

class MovieListTableViewController: UIViewController {
    
    // MARK:- IBOulet
    @IBOutlet var tableView: UITableView!
    
    // MARK:- Properties
    let cell: String = "moviecell"
    var movies: [APIResponse.MovieInfo]?
    var refresh: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidReceiveMoviesNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveErrorNotification(_:)), name: DidReceiveErrorNotification, object: nil )
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresher), for: .valueChanged)
        tableView.addSubview(refresh)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        self.title = "예매율순"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        requestMovies(orderType: 0)
    }
    
    // MARK:- Function
    @objc func didReceiveMoviesNotification(_ noti: Notification) {
        guard let movies: [APIResponse.MovieInfo] = noti.userInfo?["movies"] as? [APIResponse.MovieInfo] else { return }
        self.movies = movies
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    @objc func didReceiveErrorNotification(_ noti: Notification) {
        DispatchQueue.main.async {
            self.showErrorAlertController(style: UIAlertControllerStyle.alert)
        }
    }
    
    @objc func refresher() {
        switch self.title {
        case "예매율순":
            requestMovies(orderType: 0)
            refresh.endRefreshing()
        case "큐레이션순":
            requestMovies(orderType: 1)
            refresh.endRefreshing()
        case "개봉일순":
            requestMovies(orderType: 2)
            refresh.endRefreshing()
        default:
            refresh.endRefreshing()
        }
    }
    
    func showErrorAlertController(style: UIAlertControllerStyle) {
        let alertController = UIAlertController(title: "알림", message: "데이터를 가져오지 못하였습니다", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: false, completion: nil)
    }

    func showAlertController(style: UIAlertControllerStyle) {
        let alertController = UIAlertController(title: "정렬방식 선택", message: "영화를 어떤 순서로 정렬할까요?", preferredStyle: style)
        
        let reservationRateAction: UIAlertAction
        reservationRateAction = UIAlertAction(title: "예매율", style: UIAlertActionStyle.default, handler: { (action) in
            requestMovies(orderType: 0)
            self.title = "예매율순"
        })
        
        let curationAction: UIAlertAction
        curationAction = UIAlertAction(title: "큐레이션", style: UIAlertActionStyle.default, handler: { (action) in
            requestMovies(orderType: 1)
            self.title = "큐레이션순"
        })
        
        let dateAction: UIAlertAction
        dateAction = UIAlertAction(title: "개봉일", style: UIAlertActionStyle.default, handler: { (action) in
            requestMovies(orderType: 2)
            self.title = "개봉일순"
        })
        
        let cancelAction: UIAlertAction
        cancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(reservationRateAction)
        alertController.addAction(curationAction)
        alertController.addAction(dateAction)
        alertController.addAction(cancelAction)        
        self.present(alertController, animated: true)
    }
    
    // MARK:- IBAction
    @IBAction func touchUpSortingButton(_ sender: UIBarButtonItem) {
        self.showAlertController(style: UIAlertControllerStyle.actionSheet)
    }
    
    // MARk:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC: MovieInfoTableViewController = segue.destination as? MovieInfoTableViewController else { return }
        guard let cell = self.tableView.indexPathForSelectedRow else { return }
        guard let movies: APIResponse.MovieInfo = self.movies?[cell.row] else { return }
        nextVC.movieID = movies.id
        nextVC.title = movies.title
    }
}


// MARK:- DataSource
extension MovieListTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath) as? MovieListTableViewCell else { return UITableViewCell() }
        guard let movie: APIResponse.MovieInfo = self.movies?[indexPath.row] else { return UITableViewCell() }
        cell.movieImageView.image = nil
        DispatchQueue.global().async {
            guard let imageURL: URL = URL(string: movie.thumb) else { return }
            guard let imageData: Data = try? Data(contentsOf: imageURL) else { return }
            DispatchQueue.main.async {
                if let index: IndexPath = tableView.indexPath(for: cell) {
                    if index.row == indexPath.row {
                        cell.movieImageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
        cell.movieTitleLabel.text = movie.title
        cell.movieDateLabel.text = movie.dateFull
        cell.movieReservationGradeRateLabel.text = movie.full
        cell.movieGradeImageView.image = UIImage.gradeImage(grade: movie.grade)
        return cell
    }
}

// MARK:- Delegate
extension MovieListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120        
    }
}














