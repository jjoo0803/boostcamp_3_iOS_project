import UIKit

class MovieListCollectionViewController: UIViewController {
    
    // MARK:- IBOulet
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK:- Properties
    let cell: String = "moviecell"
    var movies: [APIResponse.MovieInfo]?
    var refresh: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        let halfWidth = UIScreen.main.bounds.width / 2.0 - 10
        flowLayout.itemSize = CGSize(width: halfWidth, height: 280)
        self.collectionView.collectionViewLayout = flowLayout
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMoviesNotification(_:)), name: DidReceiveMoviesNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveErrorNotification(_:)), name: DidReceiveErrorNotification, object: nil )
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresher), for: .valueChanged)
        collectionView.addSubview(refresh)
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
            self.collectionView.reloadData()
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
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC: MovieInfoTableViewController = segue.destination as? MovieInfoTableViewController else { return }
        guard let cell = self.collectionView.indexPathsForSelectedItems?.first?.item else { return }
        guard let movies: APIResponse.MovieInfo = self.movies?[cell] else { return }
        nextVC.movieID = movies.id
        nextVC.title = movies.title
    }
}

// MARK:- DataSource
extension MovieListCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell, for: indexPath) as? MovieCollectionViewCell else { return UICollectionViewCell() }
        guard let movie: APIResponse.MovieInfo = self.movies?[indexPath.item] else { return UICollectionViewCell() }
        cell.movieImageView.image = nil
        DispatchQueue.global().async {
            guard let imageURL: URL = URL(string:movie.thumb) else { return }
            guard let imageData: Data = try? Data(contentsOf: imageURL) else { return }
            DispatchQueue.main.async {
                cell.movieImageView.image = UIImage(data: imageData)
            }
        }
        cell.movieTitleLabel.text = movie.title
        cell.movieDateLabel.text = movie.date
        cell.movieReservationGradeRateLabel.text = movie.collectionfull
        cell.movieGradeImageView.image = UIImage.gradeImage(grade: movie.grade)
        return cell
    }
}



