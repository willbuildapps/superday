import Foundation
import UIKit

class CustomCollectionViewArrayDatasource<Cell: UICollectionViewCell, Model: Equatable>: CustomCollectionViewDatasource
{
    typealias CellConfiguration = (_ row: Int, _ model: Model, _ cell: Cell) -> Cell
    
    private let items:[Model]
    private let cellIdentifier: String
    private let initialValue: Model?
    private let configureCell: CellConfiguration
    
    init(items: [Model], cellIdentifier: String, initialValue: Model? = nil, configureCell: @escaping CellConfiguration)
    {
        self.items = items
        self.cellIdentifier = cellIdentifier
        self.initialValue = initialValue
        self.configureCell = configureCell
    }
    
    var initialIndex: Int {
        guard let initialValue = initialValue else { return 0 }
        return items.index(of: initialValue) ?? 0
    }
    
    func numberOfItems(for collectionView: UICollectionView) -> Int
    {
        return items.count
    }
    
    func cell(at row: Int, for collectionView: UICollectionView) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: IndexPath(row: row, section: 0)) as! Cell
        let model = items[row]
        return configureCell(row, model, cell)
    }
}
