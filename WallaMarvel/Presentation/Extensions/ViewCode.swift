import Foundation

protocol ViewCode {
    func setup()
    func setupComponent()
    func setupConstrain()
    func setupExtraConfiguration()
}

extension ViewCode {
    func setup() {
        setupComponent()
        setupConstrain()
        setupExtraConfiguration()
    }

    func setupExtraConfiguration() {}
}
