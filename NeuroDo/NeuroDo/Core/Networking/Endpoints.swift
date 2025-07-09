import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

struct Endpoint {
    var path: String
    var method: HTTPMethod
    var headers: [String: String] = ["Content-Type": "application/json"]
    var body: Data? = nil
    
    var url: String {
        return "http://127.0.0.1:8000" + path
    }
}

enum APIError: Error {
    case invalidURL
    case noData
}
