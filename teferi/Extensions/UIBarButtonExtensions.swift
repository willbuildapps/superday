import Foundation
import UIKit.UIBarButtonItem

extension UIBarButtonItem
{
    static func createFixedSpace(of width: CGFloat) -> UIBarButtonItem
    {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        buttonItem.width = width
        
        return buttonItem
    }
}
