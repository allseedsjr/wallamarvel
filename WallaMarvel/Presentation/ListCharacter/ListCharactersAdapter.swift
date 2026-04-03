import Foundation
import UIKit

final class ListCharactersAdapter: NSObject, UITableViewDataSource {
    private(set) var characters: [Character] = []
    private let tableView: UITableView
    private let paginationFooter: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 52)
        return indicator
    }()

    init(tableView: UITableView, characters: [Character] = []) {
        self.tableView = tableView
        self.characters = characters
        super.init()
        self.tableView.dataSource = self
    }

    func setCharacters(_ newCharacters: [Character]) {
        characters = newCharacters
        tableView.reloadData()
    }

    func appendCharacters(_ newCharacters: [Character]) {
        let startIndex = characters.count
        characters.append(contentsOf: newCharacters)
        let indexPaths = (startIndex..<characters.count).map { IndexPath(row: $0, section: 0) }
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
        characters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCharactersTableViewCell", for: indexPath) as! ListCharactersTableViewCell
        cell.configure(model: characters[indexPath.row])
        return cell
    }
}
