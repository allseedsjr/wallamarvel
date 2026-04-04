import Foundation
import UIKit

final class ListCharactersAdapter: NSObject, UITableViewDataSource {
    private(set) var viewModels: [CharacterCellViewModel] = []
    private let tableView: UITableView
    private let paginationFooter: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 52)
        return indicator
    }()

    init(tableView: UITableView, viewModels: [CharacterCellViewModel] = []) {
        self.tableView = tableView
        self.viewModels = viewModels
        super.init()
        self.tableView.dataSource = self
    }

    func setCharacters(_ newViewModels: [CharacterCellViewModel]) {
        viewModels = newViewModels
        tableView.reloadData()
    }

    func appendCharacters(_ newViewModels: [CharacterCellViewModel]) {
        let startIndex = viewModels.count
        viewModels.append(contentsOf: newViewModels)
        let indexPaths = (startIndex..<viewModels.count).map { IndexPath(row: $0, section: 0) }
        tableView.insertRows(at: indexPaths, with: .automatic)
    }

    func showLoadingFooter() {
        paginationFooter.startAnimating()
        tableView.tableFooterView = paginationFooter
    }

    func hideLoadingFooter() {
        paginationFooter.stopAnimating()
        tableView.tableFooterView = nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCharactersTableViewCell", for: indexPath) as! ListCharactersTableViewCell
        cell.configure(viewModel: viewModels[indexPath.row])
        return cell
    }
}
