import Foundation
import UIKit
import Kingfisher

final class ListCharactersTableViewCell: UITableViewCell {

    private enum Constants {
        static let cardCornerRadius: CGFloat = 12
        static let cardHorizontalInset: CGFloat = 16
        static let cardVerticalInset: CGFloat = 4
        static let contentPadding: CGFloat = 12
        static let imageSize: CGFloat = 88
        static let imageCornerRadius: CGFloat = 8
        static let innerSpacing: CGFloat = 6
        static let statusDotSize: CGFloat = 8
        static let shadowRadius: CGFloat = 6
        static let shadowOpacity: Float = 0.5
    }

    private enum Strings {
        static let placeholderImage = "person.crop.rectangle.fill"
        static let accessibilityHint = "Double tap to see more details"
    }

    // MARK: - Card

    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 11/255.0, green: 17/255.0, blue: 32/255.0, alpha: 1)
        view.layer.cornerRadius = Constants.cardCornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = Constants.shadowRadius
        view.layer.shadowOpacity = Constants.shadowOpacity
        return view
    }()

    // MARK: - Image

    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .systemGray
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.backgroundColor = UIColor(white: 1, alpha: 0.05)
        return imageView
    }()

    // MARK: - Labels

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .adaptive(textStyle: .headline, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        return label
    }()

    private let statusDot: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.statusDotSize / 2
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .adaptive(textStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        return label
    }()

    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.font = .adaptive(textStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .lightGray
        return label
    }()

    // MARK: - Stacks

    private lazy var statusRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusDot, statusLabel])
        stack.axis = .horizontal
        stack.spacing = Constants.innerSpacing
        stack.alignment = .center
        return stack
    }()

    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, statusRow, speciesLabel])
        stack.axis = .vertical
        stack.spacing = Constants.innerSpacing
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        addSubviews()
        addConstraints()
        setupAccessibility()
    }

    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityHint = Strings.accessibilityHint
        characterImageView.isAccessibilityElement = false
        nameLabel.isAccessibilityElement = false
        statusLabel.isAccessibilityElement = false
        speciesLabel.isAccessibilityElement = false
    }

    private func addSubviews() {
        contentView.addSubview(cardView)
        cardView.addSubview(characterImageView)
        cardView.addSubview(infoStack)
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cardHorizontalInset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cardHorizontalInset),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.cardVerticalInset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.cardVerticalInset),

            characterImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Constants.contentPadding),
            characterImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Constants.contentPadding),
            characterImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Constants.contentPadding),
            characterImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            characterImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            statusDot.widthAnchor.constraint(equalToConstant: Constants.statusDotSize),
            statusDot.heightAnchor.constraint(equalToConstant: Constants.statusDotSize),

            infoStack.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: Constants.contentPadding),
            infoStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Constants.contentPadding),
            infoStack.centerYAnchor.constraint(equalTo: characterImageView.centerYAnchor),
            infoStack.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: Constants.contentPadding),
            infoStack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -Constants.contentPadding),
        ])
    }

    // MARK: - Configure

    func configure(viewModel: CharacterCellViewModel) {
        let placeholder = UIImage(systemName: Strings.placeholderImage)
        characterImageView.kf.setImage(with: viewModel.imageURL, placeholder: placeholder)
        nameLabel.text = viewModel.name
        speciesLabel.text = viewModel.species
        statusDot.backgroundColor = viewModel.statusColor
        statusLabel.text = viewModel.statusText
        accessibilityLabel = "Character: \(viewModel.name). Status: \(viewModel.statusText). \(viewModel.species)."
    }
}

