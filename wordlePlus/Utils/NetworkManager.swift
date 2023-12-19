//
//  NetworkManager.swift
//  wordlePlus
//
//  Created by Egor Zavyalov on 12.12.2023.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case requestFailed
    case invalidStatusCode
    case decodingError
}

class NetworkManager {
    
    enum Constants {
        static let baseURL: String = "http://localhost:8080"
        static let httpStatusOK: Int = 200
        static let httpStatusNotFound: Int = 404
    }
    
    private init() {}
    
    static let shared = NetworkManager()

    func fetchNewWord(ofLength length: Int, completion: @escaping (Word?, NetworkError?) -> Void) {
        let urlStr = "\(Constants.baseURL)/new_word/?length=\(length)"
        guard let url = URL(string: urlStr) else {
            completion(nil, .badURL)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                completion(nil, .requestFailed)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                completion(nil, .invalidStatusCode)
                return
            }

            do {
                let word = try JSONDecoder().decode(Word.self, from: data)
                completion(word, nil)
            } catch {
                completion(nil, .decodingError)
            }
        }
        task.resume()
    }

    func checkWord(_ word: String, completion: @escaping (Bool, NetworkError?) -> Void) {
        let urlStr = "\(Constants.baseURL)/check_word/\(word)"
        guard let url = URL(string: urlStr) else {
            completion(false, .badURL)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            guard error == nil else {
                completion(false, .requestFailed)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == Constants.httpStatusOK {
                    completion(true, nil)
                } else if httpResponse.statusCode == Constants.httpStatusNotFound  {
                    completion(false, nil)
                } else {
                    completion(false, .invalidStatusCode)
                }
            } else {
                completion(false, .invalidStatusCode)
            }
        }
        task.resume()
    }
}
