//
//  Notification+Extensions.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 26.07.2025.
//

import UIKit

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
