//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 31/10/23.
//

import UIKit

public struct CellControler {
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching    }
}

extension CellControler: Equatable {
    public static func == (lhs: CellControler, rhs: CellControler) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellControler: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
