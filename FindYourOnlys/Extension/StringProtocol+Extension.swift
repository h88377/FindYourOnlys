//
//  StringProtocol+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation

extension StringProtocol {
    
    subscript(_ offset: Int) -> Element { self[index(startIndex, offsetBy: offset)] }
    
    subscript(_ range: Range<Int>) -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    
    subscript(_ range: ClosedRange<Int>) -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
    
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    
    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence { prefix(range.upperBound) }
    
    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
}
