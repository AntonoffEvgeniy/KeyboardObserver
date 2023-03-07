import UIKit

public final class KeyboardObserver {
    public enum State {
        case initial
        case stuck
        case separated(space: CGFloat)
    }
    
    private enum Event {
        case show, change, hide
    }

    // MARK: - Private properties

    private let bottomConstraint: NSLayoutConstraint
    private let view: UIView
    private let isSafeArea: Bool
    private let isReversed: Bool
    private let state: State
    private let bottomConstraintInitialValue: CGFloat
    private var keyboardWillShowNotification: NSObjectProtocol?
    private var keyboardWillChangeNotification: NSObjectProtocol?
    private var keyboardWillHideNotification: NSObjectProtocol?

    // MARK: - Init

    public init(
        bottomConstraint: NSLayoutConstraint,
        view: UIView,
        isSafeArea: Bool = true,
        isReversed: Bool = false,
        state: State = .initial
    ) {
        assert(bottomConstraint.multiplier == 1.0, "Unsupported multipler value!")
        self.bottomConstraint = bottomConstraint
        self.view = view
        self.isSafeArea = isSafeArea
        self.isReversed = isReversed
        self.state = state
        bottomConstraintInitialValue = bottomConstraint.constant
        handleKeyboardsEvents()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private methods

    private func handleKeyboardsEvents() {
        keyboardWillShowNotification = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.keyboardDidChange(notification, event: .show)
        }
        
        keyboardWillChangeNotification = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.keyboardDidChange(notification, event: .change)
        }

        keyboardWillHideNotification = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.keyboardDidChange(notification, event: .hide)
        }
    }

    private func keyboardDidChange(_ notification: Notification, event: Event) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardFrame = frameValue.cgRectValue
        
        switch event {
        case .show, .change:
            var constraintValue = keyboardFrame.size.height
            
            /// Space between view and keyboard
            switch state {
            case .initial:
                if isReversed {
                    constraintValue += bottomConstraintInitialValue
                } else {
                    constraintValue -= bottomConstraintInitialValue
                }
            case .stuck:
                break
            case .separated(let space) where space == 0:
                break
            case .separated(let space):
                constraintValue += space
            }
            
            /// If constraint connected to safe area
            if isSafeArea {
                constraintValue -= view.safeAreaInsets.bottom
            }
            bottomConstraint.constant = isReversed ? constraintValue : -constraintValue
        case .hide:
            bottomConstraint.constant = bottomConstraintInitialValue
        }
        
        view.layoutIfNeeded()
    }
}

