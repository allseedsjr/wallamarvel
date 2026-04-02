import Foundation
import UIKit

final class ListHeroesAdapter: NSObject, UITableViewDataSource {
    var heroes: [Character] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let tableView: UITableView
    
    init(tableView: UITableView, heroes: [Character] = []) {
        self.tableView = tableView
        self.heroes = heroes
        super.init()
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        heroes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListHeroesTableViewCell", for: indexPath) as! ListHeroesTableViewCell
        
        let model = heroes[indexPath.row]
        cell.configure(model: model)
        
        return cell
    }
}
