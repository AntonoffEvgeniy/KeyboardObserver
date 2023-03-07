# KeyboardObserver
#### Simple way to handle keyboard events


## Installation

#### Swift Package Manager

##### Add the dependency to Package.swift:
```
dependencies: [
    ...
    .package(url: "https://github.com/AntonoffEvgeniy/KeyboardObserver.git", from: "1.0.0")
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "KeyboardObserver", package: "KeyboardObserver"),
    ]),
```

## Usage

```
import KeyboardObserver

class MyViewController: UIViewController {
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var keyboardObserver: KeyboardObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardObserver = KeyboardObserver(bottomConstraint: bottomConstraint, view: view)
    }
```
##### Additional parameters
- **isSafeArea: Bool** - if the constraint is connected to a safe area, `true` by default
- **isReversed: Bool** - easy to change relation items of the constraint, `false` by default
- **state: State** - one of cases, `initial` by default:
  - `initial` - space between view and keyboard wouldn't be changed
  - `stuck` - no space when keyboard is shown
  - `separated(space: CGFloat)` - custom space when keyboard is shown
