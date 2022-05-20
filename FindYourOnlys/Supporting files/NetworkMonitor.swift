//
//  NetworkMonitor.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/20.
//

import Network

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    
    private var status = NWPath.Status.requiresConnection
    
    var isReachable: Bool { status == .satisfied }
    
    private init() {
        
        startMonitoring()
    }
    
    func startMonitoring() {
        
        monitor.pathUpdateHandler = { [weak self] path in
            
            guard
                let self = self else { return }
            
            self.status = path.status
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        
        monitor.cancel()
    }
}
