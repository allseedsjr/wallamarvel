import Foundation
import UIKit
import Kingfisher

final class ListCharactersTableViewCell: UITableViewCell {
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let characterName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubviews()
        addContraints()
    }
    
    private func addSubviews() {
        addSubview(characterImageView)
        addSubview(characterName)
    }
    
    private func addContraints() {
        NSLayoutConstraint.activate([
            characterImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            characterImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            characterImageView.heightAnchor.constraint(equalToConstant: 80),
            characterImageView.widthAnchor.constraint(equalToConstant: 80),
            characterImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            characterName.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 12),
            characterName.topAnchor.constraint(equalTo: characterImageView.topAnchor, constant: 8),
        ])
    }
    
    func configure(model: Character) {
        characterImageView.kf.setImage(with: URL(string: model.imageURL))
        characterName.text = model.name
    }
}
