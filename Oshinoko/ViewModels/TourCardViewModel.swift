//
//  TourCardViewModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/15.
//

import Foundation
import Alamofire

class PlacesAPIManager: ObservableObject {
    private let apiKey = "AIzaSyBkzoY1cz_4tWupQ1rFcSqDXGCdzTEEZkU"
    private let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    
    @Published var nearbyPlaces: [Place] = []
    @Published var isLoading: Bool = false
    
    func fetchNearbyPlaces(latitude: Double, longitude: Double, radius: Int = 5000, type: String = "tourist_attraction") async {
        // メインスレッドでisLoadingをtrueに設定
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let parameters = createRequestParameters(latitude: latitude, longitude: longitude, radius: radius, type: type)
        
        // APIリクエスト (非同期で待機)
        do {
            let data = try await performRequest(with: parameters)
            DispatchQueue.main.async {
                self.isLoading = false
                self.handleSuccessResponse(data) // メインスレッドでレスポンス処理
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.handleFailureResponse(error as? AFError) // エラー処理もメインスレッドで行う
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 非同期APIリクエスト
    private func performRequest(with parameters: [String: Any]) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(baseURL, parameters: parameters).responseData { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// リクエストパラメータを生成
    private func createRequestParameters(latitude: Double, longitude: Double, radius: Int, type: String) -> [String: Any] {
        return [
            "location": "\(latitude),\(longitude)",
            "radius": radius,
            "type": type,
            "keyword": "名所",
            "key": apiKey
        ]
    }
    
    /// 成功レスポンスを処理
    private func handleSuccessResponse(_ data: Data) {
        do {
            let decodedResponse = try JSONDecoder().decode(PlacesResponse.self, from: data)
            self.nearbyPlaces = decodedResponse.results
        } catch {
            updateNearbyPlaces(with: [])
        }
    }
    
    /// 失敗レスポンスを処理
    private func handleFailureResponse(_ error: AFError?) {
        updateNearbyPlaces(with: [])
    }
    
    /// NearbyPlacesの更新
    private func updateNearbyPlaces(with places: [Place]) {
        self.nearbyPlaces = places
    }
}
