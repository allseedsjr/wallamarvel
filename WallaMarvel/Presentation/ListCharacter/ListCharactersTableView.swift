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
    }

    private enum Strings {
        static let retry = "Retry"
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
        addSubview(loadingView)
        
        loadingView.addSubview(loadingIndicator)
        errorContainerView.addSubview(errorLabel)
        errorContainerView.addSubview(retryButton)
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
        ])
    }

    func configureTableView(delegate: UITableViewDelegate) -> ListCharactersAdapter {
        charactersTableView.delegate = delegate
        return ListCharactersAdapter(tableView: charactersTableView)
    }

    func showLoading() {
        errorContainerView.isHidden = true
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
        loadingIndicator.stopAnimating()
        loadingView.isHidden = true
        charactersTableView.isHidden = false
        bringSubviewToFront(charactersTableView)
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
