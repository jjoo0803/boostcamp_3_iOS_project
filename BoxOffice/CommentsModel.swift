import Foundation

struct CommentsResponse: Codable {
    
    struct Comments: Codable {
        
        let rating: Double
        let timestamp: Double
        let contents: String
        let writer: String
        let movieId: String
        
        enum CodingKeys: String, CodingKey {
            case movieId = "movie_id"
            case rating, timestamp, contents, writer
        }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            rating = (try? values.decode(Double.self, forKey: .rating)) ?? 0
            timestamp = (try? values.decode(Double.self, forKey: .timestamp)) ?? 0
            writer = (try? values.decode(String.self, forKey: .writer)) ?? ""
            movieId = (try? values.decode(String.self, forKey: .movieId)) ?? ""
            contents = (try? values.decode(String.self, forKey: .contents)) ?? ""
        }
    }
    let comments: [Comments]
}


