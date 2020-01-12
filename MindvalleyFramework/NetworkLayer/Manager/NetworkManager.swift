//
//  NetworkManager.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

public protocol NetworkManagerProtocol {
    func request<E: XmlProvider>(_ request: E,completion: @escaping ((APIResponseResult<E.Response>) -> Void))
    func request<E: JsonProvider>(_ request: E,completion: @escaping ((APIResponseResult<E.Response>) -> Void))
    func download<E: Downloadable>(_ request: E, completion: @escaping ((APIResponseResult<Data>) -> Void))
    func cancel(_ request: APIRequestConvertible, completion: @escaping (Bool)->Void)
    func cancelAllPendingRequest()
}

typealias completionHandler = ((APIResponseResult<Data>) -> Void)

public class NetworkManager : NetworkManagerProtocol {
    
    /// Shared instance for URLSession Manager
    private let sessionStore: URLSessionManager = URLSessionManager.shared
    /// Shared Instance for CacheManager
    private let cacheManager: CacheManager = CacheManager.shared
    
    public init() {}
    
    /// API Request for JsonProvider Request.
    /// If any API Response is stored in cache, High priority is to return data from cache.
    ///
    /// - Parameters:
    ///   - request: Generic Request Object based on Provider Type specified by the user.
    ///   - completion: Completion handler used for returning API Call Result.
    public func request<E: JsonProvider>(_ request: E,completion: @escaping ((APIResponseResult<E.Response>) -> Void)) {
        
        let endpoint = request.endpoint
        let numberOfRetry = endpoint.numberOfRetry
        
        guard let urlRequest = try? endpoint.updateURLRequest(header: JSONNetworkRepository()) else {
            completion(.failure(.requestCreation))
            return
        }
        /// if API call response is already Stored in cache,
        /// If So, return data from cache.
        if let urlString = urlRequest.url?.absoluteString,
            let data = cacheManager.getItem(url: urlString) {
            
            var result: APIResponseResult<E.Response>!
            
            let jsonTranslator = JsonTranslator()
            result = jsonTranslator.convertDataResponseModel(with: .success(data))
            
            completion(result)
        } else {
            /// If API call wasn't made before i.e. response not stored in cache, Call request method for API Call.
            self.request(endpoint, request: urlRequest, numberOfRetry: numberOfRetry) { (response) in
                var result: APIResponseResult<E.Response>!
                
                let jsonTranslator = JsonTranslator()
                result = jsonTranslator.convertDataResponseModel(with: response)
                
                completion(result)
            }
        }
    }
    
    /// API Request for XMLProvider Request.
    /// If any API Response is stored in cache, High priority is to return data from cache.
    ///
    /// - Parameters:
    ///   - request: Generic Request Object based on Provider Type specified by the user.
    ///   - completion: Completion handler used for returning API Call Result.
    public func request<E: XmlProvider>(_ request: E,completion: @escaping ((APIResponseResult<E.Response>) -> Void)) {
        
        let endpoint = request.endpoint
        let numberOfRetry = endpoint.numberOfRetry
        
        guard let urlRequest = try? endpoint.updateURLRequest(header: XMLHeader()) else {
            completion(.failure(.requestCreation))
            return
        }
        /// if API call response is already Stored in cache,
        /// If So, return data from cache.
        if let urlString = urlRequest.url?.absoluteString,
            let data = cacheManager.getItem(url: urlString) {
            
            let result: APIResponseResult<E.Response>
            
            let xmlTranslator = XMLTranslator()
            result = xmlTranslator.convertDataResponseModel(with: .success(data))
            
            completion(result)
        } else {
            /// If API call wasn't made before i.e. response not stored in cache, Call request method for API Call.

            self.request(endpoint, request: urlRequest, numberOfRetry: numberOfRetry) { (response) in
                
                let result: APIResponseResult<E.Response>
                
                let xmlTranslator = XMLTranslator()
                result = xmlTranslator.convertDataResponseModel(with: response)
                
                completion(result)
            }
        }
        
    }
    
    /// API Request for Downloading Data.
    /// If any API Response is stored in cache, High priority is to return data from cache.
    ///
    /// - Parameters:
    ///   - request: Generic Request Object based on Provider Type specified by the user.
    ///   - completion: Completion handler used for returning API Call Result.
    public func download<E>(_ request: E, completion: @escaping ((APIResponseResult<Data>) -> Void)) where E : Downloadable {
        let endpoint = request.endpoint
        let numberOfRetry = endpoint.numberOfRetry
        
        guard let urlRequest = try? endpoint.updateURLRequest(header: XMLHeader()) else {
            completion(.failure(.requestCreation))
            return
        }
        
        /// if API call response is already Stored in cache,
        /// If So, return data from cache.
        if let urlString = urlRequest.url?.absoluteString,
            let data = cacheManager.getItem(url: urlString) {
            
            completion(.success(data))
        } else {
            self.request(endpoint, request: urlRequest, numberOfRetry: numberOfRetry) { (response) in
                
                let result: APIResponseResult<Data> = response
                
                completion(result)
            }
        }
        
    }
    
    /// A Generic Method required for for requesting Data (this data can be JSON, XML, Downloadable request)
    ///
    /// - Parameters:
    ///   - api: API Endpoing required for uniquely identifying any request.
    ///   - request: URL Request for making API Call via dataTask.
    ///   - numberOfRetry: number of retry used to retry call if fails
    ///   - completion: Completion handler When API Call success/failed
    private func request (_ api: APIRequestConvertible, request: URLRequest, numberOfRetry: Int, completion: @escaping completionHandler) {
        
        if numberOfRetry < 0 {
            return
        }
        
        /// Used to check if Internet is available.
        guard let reachability = Reachability()?.connection,
            reachability != .none else {
                
            completion(.failure(.internetOffline))
            return
        }
        ///The URLSessionManager based on which API call is made.
        let manager = sessionStore.sessionManager
        
        Logger.log(request: request)
        
        guard let urlString = request.url?.absoluteString else {
            completion(.failure(.requestCreation))
            return
        }
        
        ///If any call is currently in process with the same URL and parameters, That call is not made again but the completion handler is stored and when the call success/fails that stored completion handlers are executed.
        if let dataTask = sessionStore.getDataTask(for: urlString) {
            
            /// Used to set completion handlers for API call.
            sessionStore.set(dataTask, for: api, completion: completion)
        } else {
            ///If any URL Request wasn't made previously, DataTask for that request is created.
            let task = manager.dataTask(with: request) { (data, response, error) in
                
                Logger.log(response: response, error: error, data: data)
                var isFailed: Bool = false
                
                let result: APIResponseResult<Data>
                
                if let response = response as? HTTPURLResponse,
                    !(200...299).contains(response.statusCode),
                    error == nil {
                    
                    isFailed = true
                }
                if let data = data {
                    result = .success(data)
                }
                else {
                    result = .failure(.unknown)
                    isFailed = true
                }
                
                if !isFailed || numberOfRetry - 1 < 0 {
                    DispatchQueue.main.async {
                        if let data = data {
                            self.cacheManager.set(key: urlString, item: data)
                        }
                        for completion in self.sessionStore.getCompletions(for: urlString) {
                            completion(result)
                        }
                    }
                } else if isFailed {
                    self.request(api, request: request, numberOfRetry: numberOfRetry - 1, completion: completion)
                }
            }
            /// Newly created DataTask is stored, so that if same URL is requested again then Similar API Call is not processed.
            sessionStore.set(task, for: api, completion: completion)
            
            task.resume()
        }
    }
    
    /// Used to cancel any API request.
    /// The API Call is cancel based on some policies:
    /// If There are morethan 1 request made for any URL, Than
    ///
    /// - Parameters:
    ///   - request: Endpoint is provided so as to identify dataTask and API Request.
    ///   - completion: Used to identify if API call is made.
    public func cancel(_ request: APIRequestConvertible, completion: @escaping (Bool) -> Void) {
        
//        guard let urlRequest = try? request.urlRequest() else {
//            completion(false)
//            return
//        }
        
        let urlRequest = request.urlRequest()
        
        if let urlString = urlRequest.url?.absoluteString {
            
            if sessionStore.canCancelRequest(for: urlString) {
                let dataTask = sessionStore.getDataTask(for: urlString)
                dataTask?.cancel()
                completion(true)
            } else {
                sessionStore.removeRequest(for: request)
                completion(true)
            }
        }
    }
    
    public func cancelAllPendingRequest() {
        sessionStore.sessionManager.invalidateAndCancel()
        sessionStore.sessionManager = URLSession(configuration: .default)
        sessionStore.removeAllRequest()
    }
    
}
