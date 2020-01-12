//
//  URLSessionManager.swift
//  MindValleyNetworking
//
//  Created by ds-mayur on 1/4/20.
//  Copyright © 2020 Mayur Rathod. All rights reserved.
//

import Foundation

/// Used to manage URL session Request, DataTask, and currently processing API Calls.
final class URLSessionManager : NSObject, URLSessionDelegate {
    
    static var shared: URLSessionManager = URLSessionManager()
    
    /// URL Session manager required for API Calls.
    public var sessionManager: URLSession = URLSession(configuration: .default)
    /// Used to cache API Calls currently in process.
    private var dataTaskStorage: [String: SessionDataTaskModel] = [:]
    /// Used for synchronizing DataTask stored for processing parallel and similar request.
    fileprivate let queue = DispatchQueue(label: "SynchronizedDictionary", attributes: .concurrent)

    /// Use to set If new dataTask is created for API Calls, If any url request is already in process it appends completionHandler to DataStorage so similar call can never be called again untill that request is in process.
    ///
    /// - Parameters:
    ///   - dataTask: URL Request Data Task, stored in DataTaskStorage, and for future if need to cancel request.
    ///   - endPoint: Use for API Call identification purpose
    ///   - completion: CompletionHandler of requested Service, If call already in process on success of api calls fire All completionHandlers requested for API Call.
    func set(_ dataTask: URLSessionDataTask?, for endPoint: APIRequestConvertible, completion: @escaping completionHandler) {
        
        queue.sync {
            if let url = endPoint.urlRequest().url?.absoluteString {
                
                var dataTaskModel: SessionDataTaskModel?
                
                if self.dataTaskStorage.keys.contains(url) {

                    dataTaskModel = self.dataTaskStorage[url]
                    
                    if let dataTask = dataTask {
                        dataTaskModel?.dataTask = dataTask
                    }
                    
                    dataTaskModel?.currentRequestCount += 1
                    dataTaskModel?.completionHandlers[endPoint.requestUniqueIdentifier] = completion
                } else {
                    if let dataTask = dataTask {
                        dataTaskModel = SessionDataTaskModel(dataTask: dataTask, currentRequestCount: 1, completionHandlers: [endPoint.requestUniqueIdentifier: completion])
                    }
                }
                if let dataTaskModel = dataTaskModel {
                    
                    dataTaskStorage[url] = dataTaskModel
                }
            }
        }
    }
    
    /// Use to identify If can cancel call, It is based on number of API Request currently for any url request.
    ///
    /// - Parameter url: Url for which need to check Cancel Request.
    /// - Returns: Bool Based on If can cancel Any API Request.
    func canCancelRequest(for url: String) -> Bool {
        var canCancel: Bool = false
        queue.sync {
            canCancel = dataTaskStorage[url]?.currentRequestCount == 1
        }
        return canCancel
    }
    
    /// If API Request completed remove DataTask stored for that Call from storage.
    ///
    /// - Parameter url: The URL (key) against which DataTask is stored.
    func requestCompleted(for url: String) {
        _ = queue.sync {
            dataTaskStorage.removeValue(forKey: url)
        }
    }
    
    /// Used to get DataTask
    ///
    /// - Parameter url: API Call URL against which DataTask is requested.
    /// - Returns: Returns data task if contains.
    func getDataTask(for url: String) -> URLSessionDataTask? {
        
        var dataTask: URLSessionDataTask?
        queue.sync {
            dataTask = dataTaskStorage[url]?.dataTask
        }
        return dataTask
    }
    
    /// If there are more than 1 request for any task, It removes completion handler for that request, else removes the dataTask from storage.
    ///
    /// - Parameter endPoint: Endpoint against which DataTask was requested.
    func removeRequest(for endPoint: APIRequestConvertible) {
        queue.sync {
            if let url = endPoint.urlRequest().url?.absoluteString,
                dataTaskStorage.keys.contains(url) {
                
                if var dataTaskModel = dataTaskStorage[url],
                    dataTaskModel.completionHandlers.keys.contains(endPoint.requestUniqueIdentifier),
                    dataTaskModel.currentRequestCount > 1 {
                    
                    dataTaskModel.completionHandlers.removeValue(forKey: endPoint.requestUniqueIdentifier)
                    dataTaskModel.currentRequestCount -= 1
                    
                    dataTaskStorage[url] = dataTaskModel
                } else {
                    dataTaskStorage.removeValue(forKey: url)
                }
            }
        }
    }
    
    /// Use to return completion handlers stored for any API Request.
    ///
    /// - Parameter url: DataTaskModel stored against url.
    /// - Returns: Array of Completion Handlers
    func getCompletions(for url: String) -> [completionHandler] {

        var completions: [completionHandler] = []
        queue.sync {
            if let dataTask = dataTaskStorage[url] {
                completions = Array(dataTask.completionHandlers.values)
            }
        }
        return completions
    }
    
    /// Use to remove all request stored in local Cache.
    func removeAllRequest() {
        dataTaskStorage.removeAll()
    }
    
}
