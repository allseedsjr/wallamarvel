import UIKit
import Kingfisher

final class DetailCharacterViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let cardCornerRadius: CGFloat = 12
        static let cardHorizontalInset: CGFloat = 16
        static let cardSpacing: CGFloat = 16
        static let contentVerticalInset: CGFloat = 24
        static let cardPadding: CGFloat = 16
        static let rowSpacing: CGFloat = 8
        static let innerSpacing: CGFloat = 6
        static let statusDotSize: CGFloat = 8
        static let imageFadeDuration: CGFloat = 0.2
        static let shadowRadius: CGFloat = 6
        static let shadowOpacity: Float = 0.5
        static let imageHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 320 : 220
    }

    private enum Colors {
        static let card = UIColor(red: 11/255.0, green: 17/255.0, blue: 32/255.0, alpha: 1)
    }

    private enum Strings {
        static let firstSeenIn = "First seen in"
        static let retry = "Retry"
        static let rowSpecies = "Species"
        static let rowType = "Type"
        static let rowGender = "Gender"
        static let rowOrigin = "Origin"
        static let rowLocation = "Location"
        static let rowEpisodes = "Episodes"
        static let placeholderImage = "person.crop.rectangle.fill"
    }

    private let character: Character
    var presenter: DetailCharacterPresenterProtocol?

    // MARK: - Scroll

    private let scrollView = UIScrollView()

    private let scrollContent: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Card 1: Hero

    private lazy var heroCard: UIView = makeCard()

    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .systemGray
        iv.backgroundColor = UIColor(white: 1, alpha: 0.05)
        iv.layer.cornerRadius = Constants.cardCornerRadius
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.isAccessibilityElement = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .adaptive(textStyle: .title2, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.numberOfLines = 2
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

    private lazy var statusRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusDot, statusLabel])
        stack.axis = .horizontal
        stack.spacing = Constants.innerSpacing
        stack.alignment = .center
        return stack
    }()

    private lazy var heroInfoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, statusRow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.innerSpacing
        stack.alignment = .leading
        return stack
    }()

    // MARK: - Card 2: Info

    private lazy var infoCard: UIView = makeCard()

    private let infoStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = Constants.rowSpacing
        return stack
    }()

    // MARK: - Episode section (inside Card 2)

    private let episodeSectionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.firstSeenIn
        label.font = .adaptive(textStyle: .headline, weight: .semibold)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        return label
    }()

    private let episodeLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    private let episodeInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .adaptive(textStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        label.isHidden = true
        return label
    }()

    private let episodeErrorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .adaptive(textStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.retry, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        button.isHidden = true
        button.accessibilityHint = "Activates to retry loading the episode"
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
        view.backgroundColor = .black
        title = character.name
        setupScrollView()
        buildHeroCard()
        buildInfoCard()
        populate()
        Task { await presenter?.loadEpisode() }
    }

    // MARK: - Setup

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContent)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func buildHeroCard() {
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        scrollContent.addSubview(heroCard)
        heroCard.addSubview(heroImageView)
        heroCard.addSubview(heroInfoStack)

        NSLayoutConstraint.activate([
            heroCard.topAnchor.constraint(equalTo: scrollContent.topAnchor, constant: Constants.contentVerticalInset),
            heroCard.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: Constants.cardHorizontalInset),
            heroCard.trailingAnchor.constraint(equalTo: scrollContent.trailingAnchor, constant: -Constants.cardHorizontalInset),

            heroImageView.topAnchor.constraint(equalTo: heroCard.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),

            heroInfoStack.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: Constants.cardPadding),
            heroInfoStack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: Constants.cardPadding),
            heroInfoStack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -Constants.cardPadding),
            heroInfoStack.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -Constants.cardPadding),

            statusDot.widthAnchor.constraint(equalToConstant: Constants.statusDotSize),
            statusDot.heightAnchor.constraint(equalToConstant: Constants.statusDotSize)
        ])
    }

    private func buildInfoCard() {
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        scrollContent.addSubview(infoCard)
        infoCard.addSubview(infoStack)

        NSLayoutConstraint.activate([
            infoCard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: Constants.cardSpacing),
            infoCard.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: Constants.cardHorizontalInset),
            infoCard.trailingAnchor.constraint(equalTo: scrollContent.trailingAnchor, constant: -Constants.cardHorizontalInset),
            infoCard.bottomAnchor.constraint(equalTo: scrollContent.bottomAnchor, constant: -Constants.contentVerticalInset),

            infoStack.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: Constants.cardPadding),
            infoStack.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: Constants.cardPadding),
            infoStack.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -Constants.cardPadding),
            infoStack.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -Constants.cardPadding)
        ])
    }

    // MARK: - Populate

    private func populate() {
        populateHeroCard()
        populateInfoCard()
    }

    private func populateHeroCard() {
        if let url = URL(string: character.imageURL) {
            let placeholder = UIImage(systemName: Strings.placeholderImage)
            heroImageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.transition(.fade(Constants.imageFadeDuration)), .cacheOriginalImage]
            )
        }

        nameLabel.text = character.name
        nameLabel.isAccessibilityElement = true
        nameLabel.accessibilityLabel = "Character: \(character.name)"
        heroImageView.isAccessibilityElement = false

        let (statusText, statusColor, accessibleStatus): (String, UIColor, String) = {
            switch character.status.lowercased() {
            case "alive": return ("Alive", .systemGreen, "Alive")
            case "dead":  return ("Dead", .systemRed, "Dead")
            default:      return ("Unknown", .systemGray, "Unknown")
            }
        }()
        statusDot.backgroundColor = statusColor
        statusLabel.text = statusText
        statusLabel.isAccessibilityElement = true
        statusLabel.accessibilityLabel = "Status: \(accessibleStatus)"
    }

    private func populateInfoCard() {
        addInfoRow(title: Strings.rowSpecies, value: character.species)
        if !character.type.isEmpty {
            addInfoRow(title: Strings.rowType, value: character.type)
        }
        addInfoRow(title: Strings.rowGender, value: character.gender)
        addInfoRow(title: Strings.rowOrigin, value: character.originName)
        addInfoRow(title: Strings.rowLocation, value: character.locationName)
        addInfoRow(title: Strings.rowEpisodes, value: "\(character.episodeCount)")

        let separator = makeSeparator()
        infoStack.addArrangedSubview(separator)
        infoStack.setCustomSpacing(Constants.cardPadding, after: separator)

        infoStack.addArrangedSubview(episodeSectionLabel)
        infoStack.setCustomSpacing(Constants.innerSpacing, after: episodeSectionLabel)
        infoStack.addArrangedSubview(episodeLoadingIndicator)
        infoStack.addArrangedSubview(episodeInfoLabel)
        infoStack.addArrangedSubview(episodeErrorLabel)
        infoStack.addArrangedSubview(retryButton)
    }

    // MARK: - Helpers

    private func makeCard() -> UIView {
        let view = UIView()
        view.backgroundColor = Colors.card
        view.layer.cornerRadius = Constants.cardCornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = Constants.shadowRadius
        view.layer.shadowOpacity = Constants.shadowOpacity
        return view
    }

    private func addInfoRow(title: String, value: String) {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = Constants.rowSpacing
        row.distribution = .equalSpacing
        row.isAccessibilityElement = true
        row.accessibilityLabel = "\(title): \(value)"

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.adaptive(textStyle: .subheadline, weight: .semibold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.isAccessibilityElement = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .adaptive(textStyle: .subheadline)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.isAccessibilityElement = false

        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        infoStack.addArrangedSubview(row)
    }

    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
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
        episodeInfoLabel.isAccessibilityElement = true
        episodeInfoLabel.accessibilityLabel = "First seen in: \(episode.name) (\(episode.code)), \(episode.airDate)"
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
        UIAccessibility.post(notification: .screenChanged, argument: episodeErrorLabel)
    }
}

