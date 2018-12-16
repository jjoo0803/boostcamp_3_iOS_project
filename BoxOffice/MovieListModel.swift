import Foundation

struct APIResponse: Codable {
    
    struct MovieInfo: Codable {
        let grade: Int
        let thumb: String
        let reservationGrade: Int
        let title: String
        let reservationRate: Double
        let userRating: Double
        let date: String
        let id: String
        
        var full: String {
            return "평점 : \(String(userRating)) 예매순위 : \(String(reservationGrade)) 예매율 : \(String(reservationRate))"
        }
        
        var dateFull: String {
            return "개봉일 : \(date)"
        }
        
        var collectionfull: String {
            return "\(String(reservationGrade))위(\(String(userRating))) / \(String(reservationRate))%"
        }
        
        enum CodingKeys: String, CodingKey {
            case reservationGrade = "reservation_grade"
            case reservationRate = "reservation_rate"
            case userRating = "user_rating"
            case grade, thumb, title, date, id
        }
    }

    let orderType: Int
    let movies: [MovieInfo]

    enum CodingKeys: String, CodingKey {
        case orderType = "order_type"
        case movies
    }
}



