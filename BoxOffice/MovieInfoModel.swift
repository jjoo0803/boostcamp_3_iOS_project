import Foundation

struct MovieInfoResponse: Codable {
    let actor: String
    let image: String
    let title: String
    let duration: Int
    let reservationGrade: Int
    let id: String
    let grade: Int
    let synopsis: String
    let audience: Int
    let genre: String
    let userRating: Double
    let reservationRate: Double
    let director: String
    let date: String
    
    var datefull: String {
        return date + "개봉"
    }
    var genreDurationFull: String {
        return genre + "/" + String(duration) + "분"
    }
    var reservationGradeReservationRateFull: String {
        return String(reservationGrade)+"위 " + String(reservationRate) + "%"
    }
    var userRatinString: String {
        return String(userRating)
    }
    var audienceString: String {
        return String(audience)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case reservationGrade = "reservation_grade"
        case userRating = "user_rating"
        case reservationRate = "reservation_rate"
        case actor, image, title, duration, id, grade, synopsis, audience, genre, director, date

    }
}

