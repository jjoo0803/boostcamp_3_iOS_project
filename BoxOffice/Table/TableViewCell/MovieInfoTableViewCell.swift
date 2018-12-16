import UIKit

class MovieInfoTableViewCell: UITableViewCell {

    @IBOutlet var movieImageView: UIImageView!
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var movieDateLabel: UILabel!
    @IBOutlet var movieGenreLabel: UILabel!
    @IBOutlet var movieGradeImageView: UIImageView!
    @IBOutlet var movieReservationRateLabel: UILabel!
    @IBOutlet var userRateLabel: UILabel!
    @IBOutlet var audienceLabel: UILabel!
    @IBOutlet var movieImageButton: UIButton!
    @IBOutlet var ratingStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
