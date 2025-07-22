//
//  Error+Extensions.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 21.07.2025.
//

import Foundation

extension Error {
    var isCancellationError: Bool {
        (self as? URLError)?.code == .cancelled ||
        (self as NSError).code == NSURLErrorCancelled ||
        (self as? CancellationError) != nil
    }
}
