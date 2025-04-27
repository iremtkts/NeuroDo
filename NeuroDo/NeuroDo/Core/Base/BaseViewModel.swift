import Foundation

class BaseViewModel {
    
    var isLoading: Bool = false {
        didSet {
            onLoadingStateChange?(isLoading)
        }
    }
    var onError: ((String) -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    
    
    func handleError(_ error: Error) {
        onError?(error.localizedDescription)
    }
}
