import Foundation
import UIKit

final class ListCharactersView: UIView {
    private enum Constants {
        static let estimatedRowHeight: CGFloat = 120
        static let errorLabelHorizontalInset: CGFloat = 24
        static let errorLabelVerticalOffset: CGFloat = -40
        static let retryButtonTopSpacing: CGFloat = 24
        static let retryButtonWidth: CGFloat = 120
        static let retryButtonHeight: CGFloat = 44
        static let retryButtonCornerRadius: CGFloat = 8
        static let fontSize: CGFloat = 16
        static let emptySearchIconSize: CGFloat = 60
        static let emptySearchSpacing: CGFloat = 16
        static let emptySearchHorizontalInset: CGFloat = 32
    }

    private enum Strings {
        static let retry = "Retry"
        static let emptySearchTitle = "No characters found"
        static let emptySearchMessage = "Try a different name."
    }
    
    private let charactersTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ListCharactersTableViewCell.self, forCellReuseIdentifier: "ListCharactersTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        return tableView
    }()
    
    private let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    private let errorContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()

    private let emptySearchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.isHidden = true
        view.accessibilityElements = []
        return view
    }()

    private let emptySearchIconView: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .secondaryLabel
        image.contentMode = .scaleAspectFit
        image.isAccessibilityElement = false
        return image
    }()

    private let emptySearchTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.emptySearchTitle
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        label.isAccessibilityElement = false
        return label
    }()

    private let emptySearchMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.emptySearchMessage
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isAccessibilityElement = false
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.textColor = .darkText
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Strings.retry, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.retryButtonCornerRadius
        button.accessibilityHint = "Activates to reload the character list"
        return button
    }()
    
    init() {
        super.init(frame: .zero)
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
        addSubview(charactersTableView)
        addSubview(errorContainerView)
        addSubview(emptySearchContainerView)
        addSubview(loadingView)

        loadingView.addSubview(loadingIndicator)
        errorContainerView.addSubview(errorLabel)
        errorContainerView.addSubview(retryButton)
        emptySearchContainerView.addSubview(emptySearchIconView)
        emptySearchContainerView.addSubview(emptySearchTitleLabel)
        emptySearchContainerView.addSubview(emptySearchMessageLabel)
    }
    
    private func addContraints() {
        NSLayoutConstraint.activate([
            charactersTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            charactersTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            charactersTableView.topAnchor.constraint(equalTo: topAnchor),
            charactersTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
            
            errorContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorContainerView.topAnchor.constraint(equalTo: topAnchor),
            errorContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            errorLabel.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor, constant: Constants.errorLabelHorizontalInset),
            errorLabel.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor, constant: -Constants.errorLabelHorizontalInset),
            errorLabel.centerYAnchor.constraint(equalTo: errorContainerView.centerYAnchor, constant: Constants.errorLabelVerticalOffset),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: Constants.retryButtonTopSpacing),
            retryButton.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: Constants.retryButtonWidth),
            retryButton.heightAnchor.constraint(equalToConstant: Constants.retryButtonHeight),

            emptySearchContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptySearchContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptySearchContainerView.topAnchor.constraint(equalTo: topAnchor),
            emptySearchContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptySearchIconView.centerXAnchor.constraint(equalTo: emptySearchContainerView.centerXAnchor),
            emptySearchIconView.centerYAnchor.constraint(equalTo: emptySearchContainerView.centerYAnchor, constant: -Constants.emptySearchSpacing * 2),
            emptySearchIconView.widthAnchor.constraint(equalToConstant: Constants.emptySearchIconSize),
            emptySearchIconView.heightAnchor.constraint(equalToConstant: Constants.emptySearchIconSize),

            emptySearchTitleLabel.topAnchor.constraint(equalTo: emptySearchIconView.bottomAnchor, constant: Constants.emptySearchSpacing),
            emptySearchTitleLabel.leadingAnchor.constraint(equalTo: emptySearchContainerView.leadingAnchor, constant: Constants.emptySearchHorizontalInset),
            emptySearchTitleLabel.trailingAnchor.constraint(equalTo: emptySearchContainerView.trailingAnchor, constant: -Constants.emptySearchHorizontalInset),

            emptySearchMessageLabel.topAnchor.constraint(equalTo: emptySearchTitleLabel.bottomAnchor, constant: Constants.emptySearchSpacing / 2),
            emptySearchMessageLabel.leadingAnchor.constraint(equalTo: emptySearchContainerView.leadingAnchor, constant: Constants.emptySearchHorizontalInset),
            emptySearchMessageLabel.trailingAnchor.constraint(equalTo: emptySearchContainerView.trailingAnchor, constant: -Constants.emptySearchHorizontalInset),
        ])
    }

    func configureTableView(delegate: UITableViewDelegate) -> ListCharactersAdapter {
        charactersTableView.delegate = delegate
        return ListCharactersAdapter(tableView: charactersTableView)
    }

    func showLoading() {
        errorContainerView.isHidden = true
        emptySearchContainerView.isHidden = true
        charactersTableView.isHidden = true
        loadingView.isHidden = false
        bringSubviewToFront(loadingView)
        loadingIndicator.startAnimating()
    }

    func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingView.isHidden = true
    }

    func showCharacters() {
        errorContainerView.isHidden = true
        emptySearchContainerView.isHidden = true
        loadingIndicator.stopAnimating()
        loadingView.isHidden = true
        charactersTableView.isHidden = false
        bringSubviewToFront(charactersTableView)
    }

    func showEmptySearch() {
        charactersTableView.isHidden = true
        emptySearchContainerView.isHidden = false
        bringSubviewToFront(emptySearchContainerView)
        emptySearchContainerView.isAccessibilityElement = true
        emptySearchContainerView.accessibilityLabel = "\(Strings.emptySearchTitle). \(Strings.emptySearchMessage)"
        UIAccessibility.post(notification: .screenChanged, argument: emptySearchContainerView)
    }

    func showError(message: String) {
        charactersTableView.isHidden = true
        loadingIndicator.stopAnimating()
        loadingView.isHidden = true
        errorContainerView.isHidden = false
        bringSubviewToFront(errorContainerView)
        errorLabel.text = message
        UIAccessibility.post(notification: .screenChanged, argument: errorLabel)
    }

    func setRetryEnabled(_ isEnabled: Bool) {
        retryButton.isEnabled = isEnabled
    }

    func setRetryTarget(_ target: Any?, action: Selector) {
        retryButton.removeTarget(nil, action: nil, for: .allEvents)
        retryButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
