import UIKit.UIGestureRecognizerSubclass

// MARK: - Geometry helpers

private func + (a: CGPoint, b: CGPoint) -> CGPoint { CGPoint(x: a.x + b.x, y: a.y + b.y) }
private func - (a: CGPoint, b: CGPoint) -> CGPoint { CGPoint(x: a.x - b.x, y: a.y - b.y) }
private func * (a: CGPoint, m: CGFloat) -> CGPoint { CGPoint(x: a.x * m, y: a.y * m) }
private func offset(_ a: CGPoint, _ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: a.x + x, y: a.y + y) }
private func mid(_ a: CGPoint, _ b: CGPoint) -> CGPoint { CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2) }
private func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }
private func proportional(_ a: CGPoint, in b: CGSize) -> CGPoint { CGPoint(x: a.x / b.width, y: a.y / b.height) }
private func fromProportional(_ a: CGPoint, in b: CGSize) -> CGPoint { CGPoint(x: a.x * b.width, y: a.y * b.height) }
private func mul(_ s: CGSize, _ m: CGFloat) -> CGSize { CGSize(width: s.width * m, height: s.height * m) }
private func isValid(_ p: CGPoint) -> Bool { !p.x.isNaN && !p.y.isNaN }

// MARK: - View state

/// The transform state of one photo the scroll view is tracking: its view, the
/// base scale that fits it to the viewport, and the user's zoom `scale` on top.
@MainActor
final class PhotoScrollViewState {
	var view: UIView?
	/// The user's zoom relative to `baseScale`; 1 means fitted.
	var scale: CGFloat = 1
	/// The scale that fits the view to the viewport (governed by `maximumBaseScale`).
	var baseScale: CGFloat = 0
	/// The tilt of the view in radians, clockwise; 0 except during a swipe dismissal.
	var rotation: CGFloat = 0
	var indexPath: IndexPath?
	/// A stand-in view awaiting its real image; may be replaced in place.
	var placeholder = false

	func copy() -> PhotoScrollViewState {
		let c = PhotoScrollViewState()
		c.view = view
		c.scale = scale
		c.baseScale = baseScale
		c.rotation = rotation
		c.indexPath = indexPath
		c.placeholder = placeholder
		return c
	}
}

// MARK: - Protocols

/// Supplies the photo scroll view with its column/row counts and, on demand, the
/// view for a given position (delivered back via `setView(_:at:placeholder:)`,
/// possibly asynchronously).
@MainActor
public protocol PhotoScrollViewDataSource: AnyObject {
	func numberOfColumns(in view: PhotoScrollView) -> Int
	func numberOfRows(in view: PhotoScrollView) -> Int
	func photoScrollView(_ view: PhotoScrollView, requestViewAt indexPath: IndexPath)
	func photoScrollView(_ view: PhotoScrollView, cancelRequestAt indexPath: IndexPath)
}

extension PhotoScrollViewDataSource {
	public func numberOfRows(in view: PhotoScrollView) -> Int { 1 }
	public func photoScrollView(_ view: PhotoScrollView, cancelRequestAt indexPath: IndexPath) {}
}

/// Notifies about navigation and gestures. All methods are optional.
@MainActor
public protocol PhotoScrollViewDelegate: AnyObject {
	func photoScrollView(_ view: PhotoScrollView, didChangeTo indexPath: IndexPath)
	func photoScrollView(_ view: PhotoScrollView, didTap subview: UIView?, at point: CGPoint, indexPath: IndexPath)
	func photoScrollView(_ view: PhotoScrollView, didLongPress subview: UIView?, at point: CGPoint, indexPath: IndexPath)
	func photoScrollView(_ view: PhotoScrollView, didPinchDismiss subview: UIView?, indexPath: IndexPath)
	/// How far the current view has been pulled towards a swipe dismissal:
	/// 0 at rest, 1 once its centre reaches the viewport edge. Reported both
	/// while dragging and while a cancelled drag settles back to 0.
	func photoScrollView(_ view: PhotoScrollView, didUpdateDismissProgress progress: CGFloat)
	/// The current view has been flung fully off screen by a swipe dismissal.
	func photoScrollView(_ view: PhotoScrollView, didSwipeDismiss subview: UIView?, indexPath: IndexPath)
}

extension PhotoScrollViewDelegate {
	public func photoScrollView(_ view: PhotoScrollView, didChangeTo indexPath: IndexPath) {}
	public func photoScrollView(_ view: PhotoScrollView, didTap subview: UIView?, at point: CGPoint, indexPath: IndexPath) {}
	public func photoScrollView(_ view: PhotoScrollView, didLongPress subview: UIView?, at point: CGPoint, indexPath: IndexPath) {}
	public func photoScrollView(_ view: PhotoScrollView, didPinchDismiss subview: UIView?, indexPath: IndexPath) {}
	public func photoScrollView(_ view: PhotoScrollView, didUpdateDismissProgress progress: CGFloat) {}
	public func photoScrollView(_ view: PhotoScrollView, didSwipeDismiss subview: UIView?, indexPath: IndexPath) {}
}

// MARK: - Gesture recognizer

/// Forwards raw multi-touch events to its photo scroll view, which owns all the
/// drag/zoom logic. Recognition begins once the scroll view claims the touches.
private final class PhotoScrollGestureRecognizer: UIGestureRecognizer {
	weak var photoScrollView: PhotoScrollView?

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		photoScrollView?.startTouches(event.allTouches ?? touches)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
		if photoScrollView?.moveTouches(event: event) == true {
			state = state == .possible ? .began : .changed
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		if photoScrollView?.endTouches(touches) == true { state = .ended }
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
		if photoScrollView?.endTouches(touches) == true { state = .cancelled }
	}
}

// MARK: - PhotoScrollView

/// A swipeable, zoomable photo viewer modelled on the iOS Photos app, ported from
/// the Objective-C `XKPhotoScrollView`. It hosts one photo at a time (plus the
/// adjacent one being revealed mid-swipe), scaling each to fit and letting the
/// user drag between photos, pinch to zoom around the fingers, and pinch past the
/// fitted scale to dismiss. With `swipeToDismissEnabled`, a fitted photo can also
/// be dragged vertically and flicked off screen to dismiss, and it tilts and
/// spins as it goes (see `maximumDismissRotation`). Provide content
/// through a `dataSource` and observe navigation through a `delegate`.
///
/// Use this where a plain scroll view's nested zoom/paging arbitration falls
/// short: it drives everything from raw touches, so gestures compose cleanly.
///
/// The photos are in a grid of columns and rows: an index path's `section` is
/// the column and its `row` is the row. Set the data source, then call
/// `reloadData()` to show the first photo, or the photo of
/// `setInitialIndexPath(_:)`.
public final class PhotoScrollView: UIView {
	/// Supplies the number of photos and the view of each photo.
	public weak var dataSource: PhotoScrollViewDataSource?
	/// Receives navigation and gesture events.
	public weak var delegate: PhotoScrollViewDelegate?

	/// True when a pinch can zoom past the minimum and maximum zoom scales, and
	/// the photo then springs back to the limit.
	public var bouncesZoom = true
	/// True when a horizontal drag moves a lone photo, which then springs back.
	public var alwaysBounceScroll = false
	/// Max zoom relative to the base (fitted) scale.
	public var maximumZoomScale: CGFloat = 3
	/// Min zoom relative to the base (fitted) scale.
	public var minimumZoomScale: CGFloat = 1
	/// Cap on enlarging a view to fit; large values fit small images to the screen.
	public var maximumBaseScale: CGFloat = 1
	/// How a photo fits the viewport at its base scale.
	public var fillMode: FillMode = .aspectFit
	/// The distance, in points, that a finger moves before a touch becomes a drag.
	public var minimumDrag: CGFloat = 5
	/// The time that a finger rests before a touch becomes a long press.
	public var minimumLongPressDuration: TimeInterval = 0.4
	/// The margins that a zoomed photo keeps from the edges of the viewport.
	public var insets: UIEdgeInsets = .zero
	/// The margins that a fitted photo keeps from the edges of the viewport.
	public var baseInsets: UIEdgeInsets = .zero
	/// True when a predominantly vertical drag at the fitted scale pulls the photo
	/// towards dismissal, when there is a single row. The delegate receives
	/// progress updates, and releasing with enough displacement or velocity
	/// flings the photo off screen and reports a swipe dismiss; otherwise the
	/// photo settles back into place.
	public var swipeToDismissEnabled = false
	/// The largest tilt, in radians, of a photo during a swipe dismissal. The
	/// photo turns as if the finger holds it at the point where the drag began,
	/// and it keeps turning as it falls off the screen. Set it to 0 for a photo
	/// that moves without turning.
	public var maximumDismissRotation: CGFloat = .pi / 18

	/// How a photo fits the viewport at its base scale.
	public enum FillMode {
		/// The whole photo shows, so there may be space beside it.
		case aspectFit
		/// The photo covers the viewport, so some of it may be outside.
		case aspectFill
	}

	private enum TouchMode { case none, dragging, zooming }
	private enum DragAxis { case none, vertical, horizontal, dismiss }
	private enum RevealMode { case none, up, down, right, left }

	private static let revealGutter: CGFloat = 40

	private let contentView = UIView()

	private var currentState = PhotoScrollViewState()
	private var revealState = PhotoScrollViewState()
	private var revealMode: RevealMode = .none

	private var cols = 0, rows = 0

	private var animationStartCenter = CGPoint.zero
	private var animationTargetCenter = CGPoint.zero
	private var animationStartScale: CGFloat = 0
	private var animationTargetScale: CGFloat = 0
	/// The tilt that a settle animation starts from; it always ends level.
	private var animationStartRotation: CGFloat = 0
	private var animationStartTime: TimeInterval = 0
	private var animationDuration: TimeInterval = 0
	private var decelerating = false
	private var displayLink: CADisplayLink?

	private var touchMode: TouchMode = .none
	private var lastTouchMode: TouchMode = .none

	private var currentSize = CGSize.zero

	private var zoomTouchStart = CGPoint.zero
	private var zoomCurrentViewStart = CGPoint.zero
	private var zoomRadiusStart: CGFloat = 0
	private var zoomScaleStart: CGFloat = 0
	private var zoomScaleTarget: CGFloat = 0
	private var zoomMaxScale: CGFloat = 0
	private var zoomMinScale: CGFloat = 0

	private var dragTouchStart = CGPoint.zero
	private var dragTouchLast = CGPoint.zero
	private var dragTouchLastTime: TimeInterval = 0
	private var dragCurrentViewStart = CGPoint.zero
	private var dragLastVector = CGPoint.zero
	private var dragAxis: DragAxis = .none
	private var draggedSomeDistance = false

	/// Tracking for a swipe-to-dismiss drag: the smoothed finger velocity while
	/// dragging, the fling velocity once released, and the progress last
	/// reported to the delegate so later animations can settle it back to 0.
	private struct DismissDrag {
		/// Smoothed finger velocity, in points/second.
		var velocity = CGPoint.zero
		/// Velocity of the fling-off animation, in points/second; the vertical
		/// component accelerates while the horizontal carries on unchanged.
		var flingVelocity = CGPoint.zero
		var lastFrameTime: TimeInterval = 0
		/// The progress last reported to the delegate (0 centred … 1 dismissed).
		var lastProgress: CGFloat = 0
		/// Where the finger holds the photo, relative to its centre, as a fraction
		/// of its half width and half height: (-1, -1) is the top-left corner.
		var grab = CGPoint.zero
		/// The spin of the fling-off animation, in radians/second, clockwise.
		var angularVelocity: CGFloat = 0
	}
	private var dismissDrag = DismissDrag()

	private static let dismissFlickVelocity: CGFloat = 700
	private static let dismissDisplacementFraction: CGFloat = 0.25
	private static let dismissGravity: CGFloat = 4500
	private static let dismissMinimumExitVelocity: CGFloat = 600
	/// How strongly a drag tilts the photo: a drag of 1/gain of the viewport
	/// height, holding the photo at its edge, reaches the maximum tilt.
	private static let dismissRotationGain: CGFloat = 5
	/// The slowest and the fastest spin of a fling, in multiples of the maximum
	/// tilt per second. The slowest spin gives a straight fling a slight turn.
	private static let dismissMinimumSpin: CGFloat = 1.5
	private static let dismissMaximumSpin: CGFloat = 6

	private let placeholderCurrentView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
	private let placeholderRevealView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

	private var request1: IndexPath?
	private var request2: IndexPath?

	private var cancelledForeignTouches = false
	private var owningTouch = false

	private var longPressLocationInView = CGPoint.zero
	private var singleTapLocationInView = CGPoint.zero

	private var pendingLongPress: DispatchWorkItem?
	private var pendingSingleTap: DispatchWorkItem?

	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	private func setup() {
		autoresizingMask = [.flexibleWidth, .flexibleHeight]
		currentSize = bounds.size

		contentView.frame = bounds
		contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(contentView)

		currentState.indexPath = makeIndexPath(row: 0, col: 0)
		isMultipleTouchEnabled = true

		let recognizer = PhotoScrollGestureRecognizer()
		recognizer.photoScrollView = self
		addGestureRecognizer(recognizer)
	}

	// MARK: Index paths

	private func makeIndexPath(row: Int, col: Int) -> IndexPath { IndexPath(row: row, section: col) }
	private func col(_ indexPath: IndexPath) -> Int { indexPath.section }

	// MARK: Configure views

	private func viewportSize() -> CGSize { contentView.bounds.size }

	public var currentView: UIView? { currentState.view }
	public var currentIndexPath: IndexPath { currentState.indexPath ?? makeIndexPath(row: 0, col: 0) }

	private func updateTransformation(_ vs: PhotoScrollViewState) {
		guard let view = vs.view else { return }
		let baseScale = vs.baseScale, scale = vs.scale
		// Guard against scaling by exactly 1.0, which logs an error on device.
		var transform: CGAffineTransform
		if scale == 1.0 {
			transform = (baseScale == 1.0 || baseScale == 0.0)
				? .identity
				: CGAffineTransform(scaleX: baseScale, y: baseScale)
		} else {
			transform = CGAffineTransform(scaleX: baseScale, y: baseScale).scaledBy(x: scale, y: scale)
		}
		if vs.rotation != 0 {
			transform = transform.rotated(by: vs.rotation)
		}
		view.transform = transform
	}

	/// Scale `viewState`'s view to fit the viewport, and optionally re-centre and
	/// reset it. Skips a view with no measurable size.
	private func configureView(_ viewState: PhotoScrollViewState, initialise: Bool) {
		guard let view = viewState.view else { return }
		let viewportSize = viewportSize()
		let viewSize = view.bounds.size
		guard viewSize.width > 0, viewSize.height > 0 else { return }

		let baseScaleWidth = (viewportSize.width - baseInsets.left - baseInsets.right) / viewSize.width
		let baseScaleHeight = (viewportSize.height - baseInsets.top - baseInsets.bottom) / viewSize.height
		var baseScale = fillMode == .aspectFit
			? min(baseScaleWidth, baseScaleHeight)
			: max(baseScaleWidth, baseScaleHeight)
		if baseScale > maximumBaseScale { baseScale = maximumBaseScale }

		// Re-centre if asked, or if the previous base scale was never valid (e.g. the
		// view was positioned while the scroll view had zero size).
		let initialiseCentre = initialise || viewState.baseScale == 0
		viewState.baseScale = baseScale

		if initialiseCentre {
			view.center = CGPoint(x: viewportSize.width / 2, y: viewportSize.height / 2)
		}
		if initialise {
			viewState.scale = 1.0
			viewState.rotation = 0
			viewState.placeholder = true
		}
		updateTransformation(viewState)
	}

	// MARK: Layout

	public override func layoutSubviews() {
		super.layoutSubviews()
		let bounds = contentView.bounds
		guard bounds.size != currentSize else { return }

		let previousSize = currentSize
		currentSize = bounds.size

		configureView(currentState, initialise: false)
		configureView(revealState, initialise: false)

		guard previousSize != .zero else { return }
		for state in [currentState, revealState] {
			guard let view = state.view else { continue }
			var center = fromProportional(proportional(view.center, in: previousSize), in: bounds.size)
			if center.x.isNaN || center.y.isNaN {
				center = fromProportional(CGPoint(x: 0.5, y: 0.5), in: bounds.size)
			}
			view.center = center
			if state === currentState { stabiliseCurrentView(animated: true) }
		}
	}

	// MARK: Data source

	private func requestView(at indexPath: IndexPath) {
		if request1 == nil {
			request1 = indexPath
		} else if request2 == nil {
			request2 = indexPath
		} else if request1 != currentState.indexPath && request1 != revealState.indexPath {
			if let stale = request1 { dataSource?.photoScrollView(self, cancelRequestAt: stale) }
			request1 = indexPath
		} else if request2 != currentState.indexPath && request2 != revealState.indexPath {
			if let stale = request2 { dataSource?.photoScrollView(self, cancelRequestAt: stale) }
			request2 = indexPath
		}
		dataSource?.photoScrollView(self, requestViewAt: indexPath)
	}

	private func cancelRequest(at indexPath: IndexPath) {
		if request1 == indexPath {
			request1 = nil
			dataSource?.photoScrollView(self, cancelRequestAt: indexPath)
		} else if request2 == indexPath {
			request2 = nil
			dataSource?.photoScrollView(self, cancelRequestAt: indexPath)
		}
	}

	public func reloadData() { reloadData(animated: false) }

	private func reloadData(animated: Bool) {
		currentState.view?.removeFromSuperview()
		revealState.view?.removeFromSuperview()

		request1 = nil
		request2 = nil
		revealState.view = nil
		revealMode = .none

		currentState.view = placeholderCurrentView
		configureView(currentState, initialise: true)
		contentView.addSubview(currentState.view!)

		cols = dataSource?.numberOfColumns(in: self) ?? 0
		rows = dataSource?.numberOfRows(in: self) ?? 1

		if !animated, let indexPath = currentState.indexPath {
			delegate?.photoScrollView(self, didChangeTo: indexPath)
		}
		if let indexPath = currentState.indexPath { requestView(at: indexPath) }
	}

	/// Deliver a view for `indexPath`. Ignored unless it matches the current or
	/// reveal position, and a placeholder never replaces a real view.
	public func setView(_ view: UIView, at indexPath: IndexPath, placeholder: Bool) {
		if !placeholder {
			if indexPath == request1 { request1 = nil }
			if indexPath == request2 { request2 = nil }
		}

		for state in [currentState, revealState] where indexPath == state.indexPath {
			guard state.view != view, !placeholder || state.placeholder else { return }
			let previous = state.view
			state.view = view
			state.placeholder = placeholder
			configureView(state, initialise: false)
			if let previous { view.center = previous.center }
			contentView.addSubview(view)
			previous?.removeFromSuperview()
			return
		}
	}

	/// The starting position, applied before the first `reloadData()`.
	public func setInitialIndexPath(_ indexPath: IndexPath) {
		currentState.indexPath = indexPath
	}

	public func setCurrentIndexPath(_ indexPath: IndexPath, animated: Bool) {
		guard indexPath != currentState.indexPath else { return }
		let saved = currentState.copy()
		currentState.indexPath = indexPath
		if animated {
			currentState.view = nil // keep reloadData from removing the outgoing view
			reloadData(animated: true)
			animate(from: saved, to: currentState)
		} else {
			reloadData(animated: false)
		}
	}

	// MARK: Transitions

	private func animate(from: PhotoScrollViewState, to: PhotoScrollViewState) {
		let saved = from.view
		to.view?.alpha = 0
		UIView.animate(withDuration: 0.5) {
			from.view?.alpha = 0
			to.view?.alpha = 1
		} completion: { _ in
			saved?.removeFromSuperview()
			if let indexPath = self.currentState.indexPath {
				self.delegate?.photoScrollView(self, didChangeTo: indexPath)
			}
		}
	}

	// MARK: Reveal (swipe between photos)

	private func halfSize(forReveal state: PhotoScrollViewState) -> CGSize {
		guard let view = state.view else { return .zero }
		var halfWidth = view.frame.width / 2
		var halfHeight = view.frame.height / 2
		let viewportSize = viewportSize()
		if halfWidth / state.scale < viewportSize.width / 2 {
			halfWidth += (viewportSize.width / 2) - (halfWidth / state.scale)
		}
		if halfHeight / state.scale < viewportSize.height / 2 {
			halfHeight += (viewportSize.height / 2) - (halfHeight / state.scale)
		}
		return CGSize(width: halfWidth, height: halfHeight)
	}

	private func shouldReveal() -> RevealMode {
		guard lastTouchMode == .dragging, let view = currentState.view else { return .none }
		let center = view.center
		let half = halfSize(forReveal: currentState)
		let viewportSize = viewportSize()
		let indexPath = currentIndexPath

		if center.x + half.width + Self.revealGutter < viewportSize.width && col(indexPath) < cols - 1 {
			return .right
		} else if center.x - half.width - Self.revealGutter > 0 && col(indexPath) > 0 {
			return .left
		} else if center.y - half.height - Self.revealGutter > 0 && indexPath.row > 0 {
			return .up
		} else if center.y + half.height + Self.revealGutter < viewportSize.height && indexPath.row < rows - 1 {
			return .down
		}
		return .none
	}

	private func moveCurrentView(_ center: CGPoint) {
		// NaNs turn up here rarely; skip them rather than corrupt the layout.
		if isValid(center) { currentState.view?.center = center }

		if revealMode == .none {
			revealMode = shouldReveal()
			let indexPath = currentIndexPath
			switch revealMode {
			case .right: revealState.indexPath = makeIndexPath(row: indexPath.row, col: col(indexPath) + 1)
			case .left: revealState.indexPath = makeIndexPath(row: indexPath.row, col: col(indexPath) - 1)
			case .up: revealState.indexPath = makeIndexPath(row: indexPath.row - 1, col: col(indexPath))
			case .down: revealState.indexPath = makeIndexPath(row: indexPath.row + 1, col: col(indexPath))
			case .none: break
			}
			if revealMode != .none, let indexPath = revealState.indexPath {
				revealState.view = placeholderRevealView
				configureView(revealState, initialise: true)
				requestView(at: indexPath)
			}
		}

		guard revealMode != .none, let revealView = revealState.view else { return }
		var revealCenter = revealView.center
		let revealHalf = halfSize(forReveal: revealState)
		let currentHalf = halfSize(forReveal: currentState)
		switch revealMode {
		case .right: revealCenter.x = center.x + currentHalf.width + revealHalf.width + Self.revealGutter
		case .left: revealCenter.x = center.x - currentHalf.width - revealHalf.width - Self.revealGutter
		case .up: revealCenter.y = center.y - currentHalf.height - revealHalf.height - Self.revealGutter
		case .down: revealCenter.y = center.y + currentHalf.height + revealHalf.height + Self.revealGutter
		case .none: break
		}
		if isValid(revealCenter) { revealView.center = revealCenter }
		if revealView.superview == nil { contentView.addSubview(revealView) }

		if shouldReveal() == .none {
			if let indexPath = revealState.indexPath { cancelRequest(at: indexPath) }
			revealState.indexPath = nil
			revealState.view?.removeFromSuperview()
			revealState.view = nil
			revealMode = .none
		}
	}

	// MARK: Stabilise

	private func stableViewZoom() {
		animationTargetScale = currentState.scale
		if zoomScaleTarget != 0 {
			animationTargetScale = zoomScaleTarget
			zoomScaleTarget = 0
		}
		animationTargetScale = min(max(animationTargetScale, minimumZoomScale), maximumZoomScale)

		guard animationTargetScale != currentState.scale else { return }
		let offsetVector = zoomCurrentViewStart - zoomTouchStart

		// Where the zoom would have landed (drags since the last zoom moved center).
		let scaledRatio = currentState.scale / zoomScaleStart
		let scaledCenter = zoomCurrentViewStart + offsetVector * (scaledRatio - 1)
		let currentDiff = animationTargetCenter - scaledCenter

		// Where we'd like to be after correcting the scale.
		let targetRatio = animationTargetScale / zoomScaleStart
		let targetCenter = zoomCurrentViewStart + offsetVector * (targetRatio - 1)

		animationTargetCenter = targetCenter + currentDiff
	}

	private func stableViewCenter() {
		guard let view = currentState.view else { return }
		let viewportSize = viewportSize()
		// Position for the scale the view will settle at. The size comes from the
		// bounds, not the frame, because the frame of a tilted view is larger, and
		// the view settles level.
		let size = mul(view.bounds.size, currentState.baseScale * animationTargetScale)
		let center = animationTargetCenter
		var stable = CGPoint.zero

		if size.width <= viewportSize.width {
			stable.x = viewportSize.width / 2
		} else {
			let half = size.width / 2
			if center.x - half > 0 {
				stable.x = half + insets.left
			} else if center.x + half < viewportSize.width {
				stable.x = viewportSize.width - half - insets.right
			} else {
				stable.x = center.x
			}
		}
		if size.height <= viewportSize.height {
			stable.y = viewportSize.height / 2
		} else {
			let half = size.height / 2
			if center.y - half > 0 {
				stable.y = half + insets.top
			} else if center.y + half < viewportSize.height {
				stable.y = viewportSize.height - half - insets.bottom
			} else {
				stable.y = center.y
			}
		}
		animationTargetCenter = stable
	}

	private func shouldSwitchToRevealed() -> Bool {
		guard let revealView = revealState.view else { return false }
		guard currentState.scale >= minimumZoomScale, currentState.scale <= maximumZoomScale else { return false }

		let revealCenter = revealView.center
		let revealHalf = halfSize(forReveal: revealState)
		let viewportSize = viewportSize()

		var revealed: CGFloat = 0
		switch revealMode {
		case .up: revealed = revealCenter.y + revealHalf.height
		case .down: revealed = viewportSize.height - revealCenter.y + revealHalf.height
		case .left: revealed = revealCenter.x + revealHalf.width
		case .right: revealed = viewportSize.width - revealCenter.x + revealHalf.width
		case .none: break
		}

		var threshold: CGFloat = 0
		switch revealMode {
		case .up, .down: threshold = currentState.scale > 1 ? revealHalf.height : 30
		case .left, .right: threshold = currentState.scale > 1 ? revealHalf.width : 30
		case .none: break
		}
		return revealed >= threshold
	}

	private func switchToRevealed() {
		swap(&currentState, &revealState)
		switch revealMode {
		case .up: revealMode = .down
		case .down: revealMode = .up
		case .left: revealMode = .right
		case .right: revealMode = .left
		case .none: break
		}
		if let indexPath = currentState.indexPath {
			delegate?.photoScrollView(self, didChangeTo: indexPath)
		}
	}

	/// Return the current view to a steady state — clamped zoom, centred or pinned
	/// within bounds — optionally animating there.
	private func stabiliseCurrentView(animated: Bool) {
		guard let view = currentState.view else { return }
		animationTargetCenter = view.center

		// Zoom before centre: centring needs the size the view is settling to.
		stableViewZoom()
		stableViewCenter()

		if animationTargetCenter == view.center && animationTargetScale == currentState.scale
			&& currentState.rotation == 0 { return }

		if animated {
			animationStartCenter = view.center
			animationStartScale = currentState.scale
			animationStartRotation = currentState.rotation
			animationStartTime = CACurrentMediaTime()
			animationDuration = 0.25
			startDisplayLink(#selector(stabiliseAnimation))
		} else {
			moveCurrentView(animationTargetCenter)
			currentState.scale = animationTargetScale
			currentState.rotation = 0
			updateTransformation(currentState)
		}
	}

	private func decelerateCurrentView() {
		if dragLastVector != .zero {
			decelerating = true
			animationStartTime = CACurrentMediaTime()
			animationDuration = 0.25
			startDisplayLink(#selector(decelerateAnimation))
		} else {
			if shouldSwitchToRevealed() { switchToRevealed() }
			stabiliseCurrentView(animated: true)
		}
	}

	private func reduceDragLastVector() {
		guard let view = currentState.view else { return }
		let center = view.center
		let halfWidth = view.frame.width / 2
		let halfHeight = view.frame.height / 2
		let viewportSize = viewportSize()
		let indexPath = currentIndexPath

		if (col(indexPath) == 0 && dragLastVector.x > 0 && center.x > halfWidth)
			|| (col(indexPath) == cols - 1 && dragLastVector.x < 0 && center.x + halfWidth < viewportSize.width) {
			dragLastVector.x /= 2
		}
		if (indexPath.row == 0 && dragLastVector.y > 0 && center.y > halfHeight)
			|| (indexPath.row == rows - 1 && dragLastVector.y < 0 && center.y + halfHeight < viewportSize.height) {
			dragLastVector.y /= 2
		}
	}

	// MARK: Display-link animations

	private func startDisplayLink(_ selector: Selector) {
		displayLink?.invalidate()
		let link = CADisplayLink(target: self, selector: selector)
		link.add(to: .current, forMode: .common)
		displayLink = link
	}

	private func linear(_ t: TimeInterval, _ begin: CGFloat, _ change: CGFloat, _ duration: TimeInterval) -> CGFloat {
		change * CGFloat(t / duration) + begin
	}

	@objc private func decelerateAnimation() {
		var t = CACurrentMediaTime() - animationStartTime
		if t > animationDuration { t = animationDuration }

		let m = linear(t, 1, -1, animationDuration)
		reduceDragLastVector()
		if let view = currentState.view {
			moveCurrentView(view.center + dragLastVector * m)
		}

		if shouldSwitchToRevealed() {
			switchToRevealed()
			t = animationDuration
		}

		if t == animationDuration || (abs(dragLastVector.x) < 1 && abs(dragLastVector.y) < 1) {
			displayLink?.invalidate()
			displayLink = nil
			decelerating = false
			stabiliseCurrentView(animated: true)
		}
	}

	@objc private func stabiliseAnimation() {
		var t = CACurrentMediaTime() - animationStartTime
		if t > animationDuration { t = animationDuration }

		let p = CGPoint(
			x: linear(t, animationStartCenter.x, animationTargetCenter.x - animationStartCenter.x, animationDuration),
			y: linear(t, animationStartCenter.y, animationTargetCenter.y - animationStartCenter.y, animationDuration))
		moveCurrentView(p)
		// A cancelled dismiss drag settles back here; walk its progress back to 0.
		if dismissDrag.lastProgress > 0 { reportDismissProgress() }

		var transformed = false
		if animationStartScale != animationTargetScale {
			currentState.scale = linear(t, animationStartScale, animationTargetScale - animationStartScale, animationDuration)
			transformed = true
		}
		// A cancelled dismiss drag also turns back to level.
		if animationStartRotation != 0 {
			currentState.rotation = linear(t, animationStartRotation, -animationStartRotation, animationDuration)
			transformed = true
		}
		if transformed { updateTransformation(currentState) }

		if t == animationDuration {
			displayLink?.invalidate()
			displayLink = nil
		}
	}

	// MARK: Drag & zoom

	private func startDrag(_ touch: UITouch) {
		dragCurrentViewStart = currentState.view?.center ?? .zero
		dragTouchStart = touch.location(in: contentView)
		dragTouchLast = dragTouchStart
		dragTouchLastTime = touch.timestamp
		touchMode = .dragging
		lastTouchMode = .dragging
		dragLastVector = .zero
		dragAxis = .none
		draggedSomeDistance = false
		dismissDrag.velocity = .zero
		dismissDrag.grab = grabPoint(dragTouchStart)
	}

	@discardableResult
	private func drag(_ touch: UITouch) -> Bool {
		if touchMode != .dragging { startDrag(touch) }

		let touchNow = touch.location(in: contentView)
		let dragVector = touchNow - dragTouchStart

		if !draggedSomeDistance {
			draggedSomeDistance = abs(dragVector.x) > minimumDrag || abs(dragVector.y) > minimumDrag
			owningTouch = draggedSomeDistance
		}

		dragLastVector = touchNow - dragTouchLast
		let dt = touch.timestamp - dragTouchLastTime
		if dt > 0 {
			dismissDrag.velocity = dismissDrag.velocity * 0.4 + dragLastVector * (0.6 / CGFloat(dt))
		}
		dragTouchLast = touchNow
		dragTouchLastTime = touch.timestamp

		if currentState.scale <= 1 {
			if dragAxis == .none, draggedSomeDistance {
				if abs(dragVector.x) > abs(dragVector.y), cols > 1 {
					dragAxis = .horizontal
				} else if rows > 1 {
					dragAxis = .vertical
				} else if swipeToDismissEnabled, abs(dragVector.y) >= abs(dragVector.x) {
					dragAxis = .dismiss
				} else if cols > 1 || alwaysBounceScroll {
					dragAxis = .horizontal
				}
			}
			if dragAxis == .dismiss {
				// Track the finger vertically (horizontal damped), bypassing the
				// reveal machinery — a dismiss drag never uncovers a neighbour.
				let center = offset(dragCurrentViewStart, dragVector.x / 2, dragVector.y)
				if isValid(center) { currentState.view?.center = center }
				let rotation = dismissRotation(for: center - dragCurrentViewStart)
				if rotation != currentState.rotation {
					currentState.rotation = rotation
					updateTransformation(currentState)
				}
				reportDismissProgress()
				return true
			}
			switch dragAxis {
			case .horizontal: dragLastVector.y = 0
			case .vertical: dragLastVector.x = 0
			case .none, .dismiss: dragLastVector = .zero // no axis locked in yet: don't move
			}
		}

		reduceDragLastVector()

		if let view = currentState.view {
			moveCurrentView(view.center + dragLastVector)
		}
		return dragLastVector != .zero
	}

	private func startZoom(_ touches: [UITouch]) {
		let pA = touches[0].location(in: contentView)
		let pB = touches[1].location(in: contentView)
		zoomCurrentViewStart = currentState.view?.center ?? .zero
		zoomTouchStart = mid(pA, pB)
		touchMode = .zooming
		lastTouchMode = .zooming
		zoomRadiusStart = dist(zoomTouchStart, pA)
		zoomScaleStart = currentState.scale
		zoomMinScale = currentState.scale
		zoomMaxScale = currentState.scale
		dragLastVector = .zero
		zoomScaleTarget = 0
	}

	@discardableResult
	private func zoom(_ touches: [UITouch]) -> Bool {
		// A two-finger move can arrive before the second finger's touch-began; start
		// the zoom now so we never divide by a zero start radius.
		if touchMode != .zooming { startZoom(touches) }

		let pA = touches[0].location(in: contentView)
		let pB = touches[1].location(in: contentView)
		let radiusNow = dist(pA, pB) / 2
		var ratio = radiusNow / zoomRadiusStart

		if !owningTouch, abs(radiusNow - zoomRadiusStart) > minimumDrag { owningTouch = true }
		guard owningTouch else { return false }

		var newScale = zoomScaleStart * ratio
		if !bouncesZoom {
			newScale = min(max(newScale, minimumZoomScale), maximumZoomScale)
		} else {
			if newScale < minimumZoomScale { newScale += (minimumZoomScale - newScale) / 1.3 }
			if newScale > maximumZoomScale { newScale -= (newScale - maximumZoomScale) / 1.3 }
		}
		zoomMinScale = min(zoomMinScale, newScale)
		zoomMaxScale = max(zoomMaxScale, newScale)

		var adjustedScale = false
		if currentState.scale != newScale {
			currentState.scale = newScale
			adjustedScale = true
		}

		ratio = newScale / zoomScaleStart
		let offsetVector = zoomCurrentViewStart - zoomTouchStart
		updateTransformation(currentState)
		moveCurrentView(zoomCurrentViewStart + offsetVector * (ratio - 1))
		return adjustedScale
	}

	// MARK: Swipe to dismiss

	/// Decide the fate of a released dismiss drag: fling the photo off screen
	/// when it was flicked hard enough or dropped far from centre, otherwise
	/// settle it back into place.
	private func finishDismissDrag() {
		guard let view = currentState.view else { return }
		let viewportHeight = viewportSize().height
		let displacement = view.center.y - viewportHeight / 2
		let flicked = abs(dismissDrag.velocity.y) > Self.dismissFlickVelocity
		let dropped = abs(displacement) > viewportHeight * Self.dismissDisplacementFraction
		guard flicked || dropped else {
			stabiliseCurrentView(animated: true)
			return
		}

		let direction: CGFloat = flicked
			? (dismissDrag.velocity.y < 0 ? -1 : 1)
			: (displacement < 0 ? -1 : 1)
		// Carry the finger's speed into the fling when it points the way out. The
		// drag tracks the finger at half speed horizontally, so carry the photo's
		// on-screen horizontal velocity, not the finger's.
		let carried = dismissDrag.velocity.y * direction > 0 ? abs(dismissDrag.velocity.y) : 0
		dismissDrag.flingVelocity = CGPoint(
			x: dismissDrag.velocity.x / 2,
			y: max(carried, Self.dismissMinimumExitVelocity) * direction)
		dismissDrag.angularVelocity = dismissSpin(for: dismissDrag.flingVelocity)
		dismissDrag.lastFrameTime = CACurrentMediaTime()
		startDisplayLink(#selector(dismissFlingAnimation))
	}

	/// Returns where a point is on the current photo, relative to its centre, as a
	/// fraction of its half width and half height, clamped to the photo.
	private func grabPoint(_ point: CGPoint) -> CGPoint {
		guard let view = currentState.view else { return .zero }
		let half = mul(view.bounds.size, currentState.baseScale * currentState.scale / 2)
		guard half.width > 0, half.height > 0 else { return .zero }
		let offset = point - view.center
		return CGPoint(
			x: min(max(offset.x / half.width, -1), 1),
			y: min(max(offset.y / half.height, -1), 1))
	}

	/// Returns the turning effect of a movement of the photo when the finger holds
	/// it at the grab point, as a fraction of the viewport height. A positive value
	/// turns the photo clockwise. It is the cross product of the grab point and the
	/// movement, so a pull below the centre and a push above it turn the same way.
	private func dismissTorque(_ movement: CGPoint) -> CGFloat {
		Self.torque(grab: dismissDrag.grab, movement: movement, height: viewportSize().height)
	}

	/// Returns the turning effect of a movement of a photo that is held at `grab`
	/// (a fraction of its half size from its centre), as a fraction of `height`.
	/// A positive value turns the photo clockwise. Returns 0 for an empty height.
	nonisolated static func torque(grab: CGPoint, movement: CGPoint, height: CGFloat) -> CGFloat {
		guard height > 0 else { return 0 }
		return (grab.x * movement.y - grab.y * movement.x) / height
	}

	/// Returns the tilt of the photo after a displacement in a dismiss drag.
	private func dismissRotation(for displacement: CGPoint) -> CGFloat {
		let amount = min(max(dismissTorque(displacement) * Self.dismissRotationGain, -1), 1)
		return amount * maximumDismissRotation
	}

	/// Returns the spin of a fling at a velocity, in radians/second. A fling always
	/// spins a little, so that a straight fling does not fall without turning. When
	/// the velocity gives no direction, the spin follows the tilt of the photo.
	private func dismissSpin(for velocity: CGPoint) -> CGFloat {
		let maximum = maximumDismissRotation
		guard maximum > 0 else { return 0 }
		var spin = dismissTorque(velocity) * Self.dismissRotationGain * maximum
		let slowest = maximum * Self.dismissMinimumSpin
		if abs(spin) < slowest {
			let turn = spin != 0 ? spin : currentState.rotation
			spin = turn < 0 ? -slowest : slowest
		}
		let fastest = maximum * Self.dismissMaximumSpin
		return min(max(spin, -fastest), fastest)
	}

	/// Let the photo fall off the screen: continue at the release velocity,
	/// accelerating in the exit direction, and notify the delegate once the
	/// photo has left the viewport entirely.
	@objc private func dismissFlingAnimation() {
		let now = CACurrentMediaTime()
		let dt = CGFloat(now - dismissDrag.lastFrameTime)
		dismissDrag.lastFrameTime = now

		guard let view = currentState.view else {
			displayLink?.invalidate()
			displayLink = nil
			return
		}

		let direction: CGFloat = dismissDrag.flingVelocity.y < 0 ? -1 : 1
		dismissDrag.flingVelocity.y += Self.dismissGravity * direction * dt
		view.center = view.center + dismissDrag.flingVelocity * dt
		if dismissDrag.angularVelocity != 0 {
			currentState.rotation += dismissDrag.angularVelocity * dt
			updateTransformation(currentState)
		}
		reportDismissProgress()

		let half = view.frame.height / 2
		if view.center.y + half < 0 || view.center.y - half > viewportSize().height {
			displayLink?.invalidate()
			displayLink = nil
			delegate?.photoScrollView(self, didSwipeDismiss: view, indexPath: currentIndexPath)
		}
	}

	/// Report the current view's dismissal progress to the delegate: 0 centred,
	/// 1 once its centre reaches the viewport edge. Repeat values are skipped.
	private func reportDismissProgress() {
		guard let view = currentState.view else { return }
		let halfHeight = viewportSize().height / 2
		guard halfHeight > 0 else { return }
		let progress = min(1, abs(view.center.y - halfHeight) / halfHeight)
		guard progress != dismissDrag.lastProgress else { return }
		dismissDrag.lastProgress = progress
		delegate?.photoScrollView(self, didUpdateDismissProgress: progress)
	}

	private func resetZoom(_ touch: UITouch) {
		zoomScaleStart = currentState.scale
		zoomScaleTarget = currentState.scale != 1.0 ? 1.0 : 2.0
		zoomCurrentViewStart = currentState.view?.center ?? .zero
		zoomTouchStart = touch.location(in: contentView)
	}

	// MARK: Timed taps

	private func scheduleLongPress() {
		let item = DispatchWorkItem { [weak self] in
			MainActor.assumeIsolated { self?.longPress() }
		}
		pendingLongPress = item
		DispatchQueue.main.asyncAfter(deadline: .now() + minimumLongPressDuration, execute: item)
	}

	private func scheduleSingleTap() {
		let item = DispatchWorkItem { [weak self] in
			MainActor.assumeIsolated { self?.singleTap() }
		}
		pendingSingleTap = item
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: item)
	}

	private func resetTimedTouches() {
		pendingLongPress?.cancel(); pendingLongPress = nil
		pendingSingleTap?.cancel(); pendingSingleTap = nil
	}

	private func singleTap() {
		delegate?.photoScrollView(self, didTap: currentState.view, at: singleTapLocationInView, indexPath: currentIndexPath)
		touchMode = .none
		lastTouchMode = .none
		decelerateCurrentView()
	}

	private func longPress() {
		delegate?.photoScrollView(self, didLongPress: currentState.view, at: longPressLocationInView, indexPath: currentIndexPath)
		touchMode = .none
		lastTouchMode = .none
		decelerateCurrentView()
	}

	// MARK: Touch handling (called by the recognizer)

	@discardableResult
	func startTouches(_ touches: Set<UITouch>) -> Bool {
		guard currentState.view != nil else { return false }
		displayLink?.invalidate()
		displayLink = nil
		resetTimedTouches()

		cancelledForeignTouches = false
		owningTouch = false

		if touches.count == 1, let touch = touches.first {
			longPressLocationInView = touch.location(in: currentState.view)
			scheduleLongPress()
			if touch.tapCount < 2 { startDrag(touch) }
		} else if touches.count == 2 {
			startZoom(Array(touches))
		}
		return true
	}

	@discardableResult
	func moveTouches(event: UIEvent) -> Bool {
		guard currentState.view != nil else { return false }
		resetTimedTouches()

		// Treat every touch as ours; interactive subviews would receive their own.
		let touches = event.allTouches ?? []
		var handled = false
		if touches.count == 1, let touch = touches.first {
			handled = drag(touch)
		} else if touches.count == 2 {
			handled = zoom(Array(touches))
		}

		if owningTouch, !cancelledForeignTouches {
			cancelledForeignTouches = true
			for touch in touches where touch.view != self {
				touch.view?.touchesCancelled([touch], with: event)
			}
		}
		return handled
	}

	@discardableResult
	func endTouches(_ touches: Set<UITouch>) -> Bool {
		guard currentState.view != nil else { return false }
		let remaining = touches.filter { $0.view != nil && $0.phase != .ended && $0.phase != .cancelled }
		guard remaining.isEmpty else { return false }
		finishedTouches(touches)
		return true
	}

	private func finishedTouches(_ touches: Set<UITouch>) {
		resetTimedTouches()

		if touchMode == .dragging {
			if !draggedSomeDistance, touches.count == 1, let touch = touches.first {
				if touch.tapCount == 1 {
					singleTapLocationInView = touch.location(in: currentState.view)
					scheduleSingleTap()
					return
				} else if touch.tapCount == 2 {
					resetZoom(touch)
				}
			}
			if dragAxis == .dismiss {
				touchMode = .none
				finishDismissDrag()
				return
			}
		} else if touchMode == .zooming {
			// A pinch-to-dismiss: begun from the fitted scale, ended more than 10%
			// below it, and never zoomed more than 5% above the start. Starting from
			// a zoomed-in photo (pinching back down to fit) must not dismiss.
			let startedFitted = zoomScaleStart <= minimumZoomScale + 0.01
			if startedFitted, currentState.scale < 0.90, zoomMaxScale <= zoomScaleStart * 1.05 {
				delegate?.photoScrollView(self, didPinchDismiss: currentState.view, indexPath: currentIndexPath)
			}
		}

		touchMode = .none
		decelerateCurrentView()
	}
}
