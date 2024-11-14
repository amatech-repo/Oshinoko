//
//  UIImage.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import Foundation
import UIKit

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvasSize).image { _ in
            draw(in: CGRect(origin: .zero, size: canvasSize))
        }
    }
}
