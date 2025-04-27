import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

struct Endpoint {
    var path: String
    var method: HTTPMethod
    var headers: [String: String] = ["Content-Type": "application/json"]
    var body: Data? = nil
    
    var url: String {
        return "http://YOUR_API_BASE_URL" + path
    }
}

enum APIError: Error {
    case invalidURL
    case noData
}
