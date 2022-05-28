//
//  Box.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

final class Box<T> {
    
    typealias Listener = (T) -> Void
    
    var listener: Listener?
    
    var value: T {
        
        didSet {
            
            listener?(value)
        }
    }
    
    init(_ value: T) {
        
        self.value = value
    }
    
    func bind(listener: Listener?) {
        
        self.listener = listener
        
        listener?(value)
    }
}
