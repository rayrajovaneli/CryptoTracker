//
//  APICaller.swift
//  CryptoTrackApp
//
//  Created by user218260 on 10/18/22.
//

// About Final classes:
// MARK: Final classes are ones that cannot be inherited from, which means it’s not possible for users of your code to add functionality or change what they have. This is not the default: you must opt in to this behavior by adding the final keyword to your class.

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants{
        static let apiKey = "2365EB53-C1D2-4765-A671-1111698437C0"
        static let assetsEndPoint = "https://rest.coinapi.io/v1/assets"
    }
    
    private init(){
    }
    
    public var icons: [Icon] = []
    
    private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void)?
    
    // MARK: - Public
    
    public func getAllCryptoData(completion: @escaping (Result<[Crypto], Error>) -> Void){
        
        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }
        
        guard let url = URL(string: Constants.assetsEndPoint + "?apikey=" + Constants.apiKey) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                // Decode Response
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                
                completion(.success(cryptos))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    public func getAllIcons(){
        guard let url = URL(string: "https://rest.coinapi.io/v1/assets/icons/55/?apikey=2365EB53-C1D2-4765-A671-1111698437C0") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                // Decode Response
                self?.icons = try JSONDecoder().decode([Icon].self, from: data)
                if let completion = self?.whenReadyBlock {
                    self?.getAllCryptoData(completion: completion)
                }
                
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}
