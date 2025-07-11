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
        return "https://neurodo-production.up.railway.app" + path
    }
}

enum APIError: Error {
    case invalidURL
    case noData
}
