import Foundation
import UIKit

final class ListCharactersAdapter: NSObject, UITableViewDataSource {
    var characters: [Character] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let tableView: UITableView
    
    init(tableView: UITableView, characters: [Character] = []) {
        self.tableView = tableView
        self.characters = characters
        super.init()
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCharactersTableViewCell", for: indexPath) as! ListCharactersTableViewCell
        
        let model = characters[indexPath.row]
        cell.configure(model: model)
        
        return cell
    }
}
