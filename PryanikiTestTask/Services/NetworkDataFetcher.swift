//
//  NetworkDataFetcher.swift
//  PryanikiTestTask
//
//  Created by Maxim Alekseev on 03.02.2021.
//

import RxCocoa
import RxSwift

final class NetworkDataFetcher  {
    
    static let shared = NetworkDataFetcher()
    
    private init() { }
    
    func fetchData<T: Decodable>(resource: Resource<T>) -> Observable<T?> {
        
        guard let url = URL(string: resource.urlString)
        else { return Observable.just(nil)}
        
        return Observable.from([url])
            .flatMap { (url) -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
        }.map { data -> T? in
            guard let decodedData =  try? JSONDecoder().decode(T.self, from: data) else { return nil }
            return decodedData
        }.asObservable()
    }
}
