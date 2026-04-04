import Foundation
import UIKit
import Kingfisher

final class ListCharactersTableViewCell: UITableViewCell {
    private enum Constants {
        static let imageSize: CGFloat = 80
        static let imageCornerRadius: CGFloat = 40
        static let outerSpacing: CGFloat = 12
        static let innerSpacing: CGFloat = 8
    }

    private enum Strings {
        static let placeholderImage = "person.crop.circle.fill"
        static let accessibilityHint = "Double tap to see more details"
    }
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .systemGray3
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        return imageView
    }()
    
    private let characterName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .adaptive(textStyle: .body)
        label.adjustsFontForContentSizeCategory = true
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
        setupAccessibility()
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityHint = Strings.accessibilityHint
        characterImageView.isAccessibilityElement = false
        characterName.isAccessibilityElement = false
    }
    
    private func addSubviews() {
        addSubview(characterImageView)
        addSubview(characterName)
    }
    
    private func addContraints() {
        NSLayoutConstraint.activate([
            characterImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.outerSpacing),
            characterImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.outerSpacing),
            characterImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),
            characterImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            characterImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.outerSpacing),
            
            characterName.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: Constants.outerSpacing),
            characterName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.outerSpacing),
            characterName.topAnchor.constraint(equalTo: characterImageView.topAnchor, constant: Constants.innerSpacing),
            characterName.centerYAnchor.constraint(equalTo: characterImageView.centerYAnchor),
        ])
    }
    
    func configure(model: Character) {
        let placeholder = UIImage(systemName: Strings.placeholderImage)
        characterImageView.kf.setImage(with: URL(string: model.imageURL), placeholder: placeholder)
        characterName.text = model.name
        accessibilityLabel = "Character: \(model.name)."
    }
}
