import UIKit

class CommentsTableViewCell: UITableViewCell {
    
//    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var witerLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var writeButton: UIButton!
    @IBOutlet var commentTitleLabel: UILabel!
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
