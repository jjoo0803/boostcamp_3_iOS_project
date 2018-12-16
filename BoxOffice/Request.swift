import Foundation
import UIKit

let DidReceiveMoviesNotification: Notification.Name = Notification.Name("DidReceiveMovies")
let DidReceiveCommentsNotification: Notification.Name = Notification.Name("DidReceiveComments")
let DidReceiveErrorNotification: Notification.Name = Notification.Name("DidReceiveError")

func requestMovies(orderType: Int) {

    let urlString: String = "http://connect-boxoffice.run.goorm.io/movies?order_type="
    guard let url: URL = URL(string:(urlString + String(orderType))) else { return }
    let session: URLSession = URLSession(configuration: .default)
    let dataTask: URLSessionDataTask = session.dataTask(with: url) { (data, reponse, error) in
        if let error = error {
            NotificationCenter.default.post(name: DidReceiveErrorNotification, object: nil, userInfo: ["Error" : error.localizedDescription])
            print(error.localizedDescription)
            return
        }
        guard let data = data else { return }  
        do {
            let apiResponse: APIResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            NotificationCenter.default.post(name: DidReceiveMoviesNotification, object: nil, userInfo: ["movies" : apiResponse.movies])
            
        } catch (let err) {
            NotificationCenter.default.post(name: DidReceiveErrorNotification, object: nil, userInfo: ["Error" : err.localizedDescription])
            print(err.localizedDescription)
        }
    }
    dataTask.resume()
}

func requestMovieInfo(id: String) {
    let urlString: String = "http://connect-boxoffice.run.goorm.io/movie?id="
    guard let url: URL = URL(string: urlString+id) else { return }
    let session: URLSession = URLSession(configuration: .default)
    let dataTask: URLSessionDataTask = session.dataTask(with: url) { (data, reponse, error) in
        if let error = error {
            NotificationCenter.default.post(name: DidReceiveErrorNotification, object: nil, userInfo: ["Error" : error.localizedDescription])
            print(error.localizedDescription)
            return
        }
        guard let data = data else { return }
        do {
            let apiResponse: MovieInfoResponse = try JSONDecoder().decode(MovieInfoResponse.self, from: data)
            NotificationCenter.default.post(name: DidReceiveMoviesNotification, object: nil, userInfo: ["movieinfo" : apiResponse])
            
        } catch (let err) {
            NotificationCenter.default.post(name: DidReceiveErrorNotification, object: nil, userInfo: ["Error" : err.localizedDescription])
            print(err.localizedDescription)
        }
    }
    dataTask.resume()
}

func requestComments(id: String) {
    let urlString: String = "http://connect-boxoffice.run.goorm.io/comments?movie_id="
    guard let url: URL = URL(string: urlString+id) else { return }
    let session: URLSession = URLSession(configuration: .default)
    let dataTask: URLSessionDataTask = session.dataTask(with: url) { (data, reponse, error) in
        if let error = error {
            NotificationCenter.default.post(name: DidReceiveErrorNotification, object: nil, userInfo: ["Error" : error.localizedDescription])
            print(error.localizedDescription)
            return
        }
        guard let data = data else { return }
        do {
            let apiResponse: CommentsResponse = try JSONDecoder().decode(CommentsResponse.self, from: data)
            NotificationCenter.default.post(name: DidReceiveCommentsNotification, object: nil, userInfo: ["comments" : apiResponse.comments])
            
        } catch (let err) {
            NotificationCenter.default.post(name: DidReceiveErrorNotification, object: nil, userInfo: ["Error" : err.localizedDescription])
            print(err.localizedDescription)
        }
    }
    dataTask.resume()
}


func postAction(movieId: String, rating: Double, contents: String, writer: String) {
    let url = String("http://connect-boxoffice.run.goorm.io/comment")
    guard let serviceUrl = URL(string: url) else { return }
    let parameterDictionary = ["movie_id" : movieId, "rating" : rating, "contents" : contents, "writer" : writer ] as [String : Any]
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = "POST"
    request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else { return }
    request.httpBody = httpBody
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
        if let response = response {
            print(response)
        }
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print("----------error----------")
                print(error)
            }
        }
        }.resume()
}
