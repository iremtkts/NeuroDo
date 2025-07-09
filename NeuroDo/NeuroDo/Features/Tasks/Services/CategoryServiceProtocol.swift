

import Foundation

protocol CategoryServiceProtocol {
    func fetchCategories(completion: @escaping ([CategoryModel]) -> Void)
}

final class CategoryService: CategoryServiceProtocol {
    static let shared = CategoryService()
    private init() {}

    func fetchCategories(completion: @escaping ([CategoryModel]) -> Void) {
        let endpoint = Endpoint(path: "/api/v1/categories/", method: .GET)

        APIService.shared.request(endpoint: endpoint, responseModel: [CategoryModel].self) { result in
            switch result {
            case .success(let categories):
                completion(categories)
            case .failure(let error):
                print("Kategorileri alırken hata: \(error)")
                completion([])
            }
        }
    }
}
