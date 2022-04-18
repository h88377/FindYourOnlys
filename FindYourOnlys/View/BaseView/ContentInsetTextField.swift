//
//  ContentInsetTextField.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ContentInsetTextField: UITextField {

    override func textRect(forBounds bounds: CGRect) -> CGRect {

        return bounds.insetBy(dx: 10, dy: 10)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {

        return bounds.insetBy(dx: 10, dy: 10)
    }

}
