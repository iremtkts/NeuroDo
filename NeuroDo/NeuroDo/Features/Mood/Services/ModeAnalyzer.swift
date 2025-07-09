//
//  ModeAnalyzer.swift
//  NeuroDo
//
//  Created by iremt on 1.05.2025.
//

import Foundation

protocol MoodAnalyzerProtocol {
    func analyzeMood(from mood: String, completion: @escaping (MoodAnalysisResponse?) -> Void)
}

final class MoodAnalyzer: MoodAnalyzerProtocol {
    func analyzeMood(from mood: String, completion: @escaping (MoodAnalysisResponse?) -> Void) {
        guard let token = TokenManager.shared.getAuthorizationHeader() else {
            print("Token bulunamadı.")
            completion(nil)
            return
        }

        let body = [
            "mode": mood
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: body)


        let endpoint = Endpoint(
            path: "/api/v1/ai/suggest",
            method: .POST,
            headers: [
                "Authorization": token,
                "Content-Type": "application/json"
            ],
            body: jsonData
        )


        APIService.shared.request(endpoint: endpoint, responseModel: MoodAnalysisResponse.self) { result in
            switch result {
            case .success(let response):
                completion(response)
            case .failure(let error):
                print("AI mood analiz hatası: \(error)")
                completion(nil)
            }
        }
    }
}
