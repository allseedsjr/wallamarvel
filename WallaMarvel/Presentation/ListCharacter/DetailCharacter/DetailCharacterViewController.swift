import UIKit
import Kingfisher

final class DetailCharacterViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let stackSpacing: CGFloat = 16
        static let contentInset: CGFloat = 16
        static let contentVerticalInset: CGFloat = 24
        static let imageSize: CGFloat = 200
        static let imageCornerRadius: CGFloat = 100
        static let badgeFontSize: CGFloat = 14
        static let badgeCornerRadius: CGFloat = 10
        static let badgeHeight: CGFloat = 28
        static let sectionFontSize: CGFloat = 17
        static let rowFontSize: CGFloat = 15
        static let rowSpacing: CGFloat = 8
        static let imageFadeDuration: CGFloat = 0.2
    }

    private enum Strings {
        static let firstSeenIn = "First seen in"
        static let retry = "Retry"
        static let statusAlive = "● Alive"
        static let statusDead = "● Dead"
        static let statusUnknown = "● Unknown"
        static let rowSpecies = "Species"
        static let rowType = "Type"
        static let rowGender = "Gender"
        static let rowOrigin = "Origin"
        static let rowLocation = "Location"
        static let rowEpisodes = "Episodes"
    }

    private let character: Character
    var presenter: DetailCharacterPresenterProtocol?

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.layoutMargins = UIEdgeInsets(
            top: Constants.contentVerticalInset,
            left: Constants.contentInset,
            bottom: Constants.contentVerticalInset,
            right: Constants.contentInset
        )
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = Constants.imageCornerRadius
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.badgeFontSize, weight: .semibold)
        label.textColor = .white
        label.layer.cornerRadius = Constants.badgeCornerRadius
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let episodeSectionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.firstSeenIn
        label.font = .systemFont(ofSize: Constants.sectionFontSize, weight: .semibold)
        return label
    }()

    private let episodeLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let episodeInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Constants.rowFontSize)
        label.isHidden = true
        return label
    }()

    private let episodeErrorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: Constants.rowFontSize)
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.retry, for: .normal)
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    // MARK: - Init

    init(character: Character, presenter: DetailCharacterPresenterProtocol? = nil) {
        self.character = character
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = character.name
        setupLayout()
        populate()
        Task { await presenter?.loadEpisode() }
    }

    // MARK: - Setup

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func populate() {
        addImageView()
        addStatusBadge()
        addInfoRows()
        addEpisodeSection()
    }

    private func addImageView() {
        let container = UIView()
        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize)
        ])
        contentStack.addArrangedSubview(container)

        if let url = URL(string: character.imageURL) {
            imageView.kf.setImage(with: url, options: [.transition(.fade(Constants.imageFadeDuration)), .cacheOriginalImage])
        }
    }

    private func addStatusBadge() {
        let status = character.status.lowercased()
        let (text, color): (String, UIColor) = {
            switch status {
            case "alive": return (Strings.statusAlive, .systemGreen)
            case "dead":  return (Strings.statusDead, .systemRed)
            default:      return (Strings.statusUnknown, .systemGray)
            }
        }()
        statusBadge.text = "  \(text)  "
        statusBadge.backgroundColor = color

        let container = UIView()
        container.addSubview(statusBadge)
        NSLayoutConstraint.activate([
            statusBadge.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            statusBadge.topAnchor.constraint(equalTo: container.topAnchor),
            statusBadge.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            statusBadge.heightAnchor.constraint(equalToConstant: Constants.badgeHeight)
        ])
        contentStack.addArrangedSubview(container)
    }

    private func addInfoRows() {
        contentStack.addArrangedSubview(makeInfoRow(title: Strings.rowSpecies, value: character.species))
        if !character.type.isEmpty {
            contentStack.addArrangedSubview(makeInfoRow(title: Strings.rowType, value: character.type))
        }
        contentStack.addArrangedSubview(makeInfoRow(title: Strings.rowGender, value: character.gender))
        contentStack.addArrangedSubview(makeInfoRow(title: Strings.rowOrigin, value: character.originName))
        contentStack.addArrangedSubview(makeInfoRow(title: Strings.rowLocation, value: character.locationName))
        contentStack.addArrangedSubview(makeInfoRow(title: Strings.rowEpisodes, value: "\(character.episodeCount)"))
    }

    private func addEpisodeSection() {
        contentStack.addArrangedSubview(episodeSectionLabel)
        contentStack.addArrangedSubview(episodeLoadingIndicator)
        contentStack.addArrangedSubview(episodeInfoLabel)
        contentStack.addArrangedSubview(episodeErrorLabel)
        contentStack.addArrangedSubview(retryButton)
    }

    private func makeInfoRow(title: String, value: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = Constants.rowSpacing
        row.distribution = .equalSpacing

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: Constants.rowFontSize, weight: .semibold)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: Constants.rowFontSize)
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0

        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        return row
    }

    // MARK: - Actions

    @objc private func retryTapped() {
        Task { await presenter?.loadEpisode() }
    }
}

// MARK: - DetailCharacterUI

extension DetailCharacterViewController: DetailCharacterUI {
    func showEpisodeLoading() {
        episodeLoadingIndicator.startAnimating()
        episodeInfoLabel.isHidden = true
        episodeErrorLabel.isHidden = true
        retryButton.isHidden = true
    }

    func showEpisode(_ episode: Episode) {
        episodeLoadingIndicator.stopAnimating()
        episodeInfoLabel.text = "\(episode.name) (\(episode.code))\n\(episode.airDate)"
        episodeInfoLabel.isHidden = false
        episodeErrorLabel.isHidden = true
        retryButton.isHidden = true
    }

    func showEpisodeError(_ error: AppError) {
        episodeLoadingIndicator.stopAnimating()
        episodeErrorLabel.text = error.userMessage
        episodeErrorLabel.isHidden = false
        episodeInfoLabel.isHidden = true
        retryButton.isHidden = false
    }
}

