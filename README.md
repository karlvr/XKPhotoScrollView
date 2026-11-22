# XKPhotoScrollView

`PhotoScrollView` is a `UIView` subclass that shows a swipeable, zoomable photo viewer, modelled on
the iOS Photos app. It shows one photo at a time, and the next photo slides in during a swipe. The
user can drag between photos, pinch to zoom around the fingers, and pinch below the fitted scale to
dismiss. A fitted photo can also be flicked off the screen to dismiss.

The view takes all of its gestures from the raw touches, so the swipe, the zoom and the dismissal do
not compete with each other, as nested scroll views do.

Version 1 is a Swift port of the Objective-C `XKPhotoScrollView`. The API changed, and the package
does not support CocoaPods.

## Installation

Add the package with Swift Package Manager:

```swift
.package(url: "https://github.com/karlvr/XKPhotoScrollView", from: "1.0.0"),
```

The package needs iOS 15 or later.

## Usage

The photos are in a grid of columns and rows. In an index path, `section` is the column and `row`
is the row. A data source gives the size of the grid and a view for each photo. It can give the view
later, for example after a download, and it can give a placeholder first.

```swift
import XKPhotoScrollView

final class PhotosViewController: UIViewController, PhotoScrollViewDataSource, PhotoScrollViewDelegate {
	var images: [UIImage] = []

	override func loadView() {
		let photoScrollView = PhotoScrollView()
		photoScrollView.dataSource = self
		photoScrollView.delegate = self
		photoScrollView.swipeToDismissEnabled = true
		view = photoScrollView
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		(view as? PhotoScrollView)?.reloadData()
	}

	// MARK: PhotoScrollViewDataSource

	func numberOfColumns(in view: PhotoScrollView) -> Int {
		images.count
	}

	func photoScrollView(_ view: PhotoScrollView, requestViewAt indexPath: IndexPath) {
		let imageView = UIImageView(image: images[indexPath.section])
		view.setView(imageView, at: indexPath, placeholder: false)
	}

	// MARK: PhotoScrollViewDelegate

	func photoScrollView(_ view: PhotoScrollView, didSwipeDismiss subview: UIView?, indexPath: IndexPath) {
		dismiss(animated: true)
	}
}
```

The delegate methods are optional. The delegate receives a change of photo, a tap, a long press, a
pinch to dismiss, and the progress and the end of a swipe to dismiss.

## Features

- Asynchronous delivery of views, with placeholders that a final view replaces
- Minimum and maximum zoom scales, a maximum base scale, and zoom bounce
- Aspect fit or aspect fill
- Swipe to dismiss, with progress for a fade of the background
- Pinch to dismiss

## Tests

```shell
xcodebuild test -scheme XKPhotoScrollView -destination "platform=iOS Simulator,name=<simulator>"
```

## Author

Karl von Randow, karl@xk72.com

## License

XKPhotoScrollView is available under the MIT license. See the LICENSE file for more info.
