import Testing
import UIKit
@testable import XKPhotoScrollView

/// A data source with a fixed number of columns, which records the requests of the view.
@MainActor
private final class RecordingDataSource: PhotoScrollViewDataSource {
	let columns: Int
	var requested: [IndexPath] = []

	init(columns: Int) {
		self.columns = columns
	}

	func numberOfColumns(in view: PhotoScrollView) -> Int { columns }

	func photoScrollView(_ view: PhotoScrollView, requestViewAt indexPath: IndexPath) {
		requested.append(indexPath)
	}
}

/// A delegate that records the index paths that the view reports.
@MainActor
private final class RecordingDelegate: PhotoScrollViewDelegate {
	var changes: [IndexPath] = []

	func photoScrollView(_ view: PhotoScrollView, didChangeTo indexPath: IndexPath) {
		changes.append(indexPath)
	}
}

@MainActor
struct PhotoScrollViewTests {

	private func makeView(columns: Int) -> (PhotoScrollView, RecordingDataSource, RecordingDelegate) {
		let view = PhotoScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
		let dataSource = RecordingDataSource(columns: columns)
		let delegate = RecordingDelegate()
		view.dataSource = dataSource
		view.delegate = delegate
		view.layoutIfNeeded()
		return (view, dataSource, delegate)
	}

	@Test func reloadRequestsTheFirstPhoto() {
		let (view, dataSource, delegate) = makeView(columns: 3)
		view.reloadData()

		let first = IndexPath(row: 0, section: 0)
		#expect(dataSource.requested == [first])
		#expect(delegate.changes == [first])
		#expect(view.currentIndexPath == first)
	}

	@Test func reloadStartsAtTheInitialIndexPath() {
		let (view, dataSource, _) = makeView(columns: 3)
		let second = IndexPath(row: 0, section: 1)
		view.setInitialIndexPath(second)
		view.reloadData()

		#expect(dataSource.requested == [second])
		#expect(view.currentIndexPath == second)
	}

	@Test func aDeliveredViewFitsTheViewport() {
		let (view, _, _) = makeView(columns: 1)
		view.reloadData()

		let photo = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 300))
		view.setView(photo, at: IndexPath(row: 0, section: 0), placeholder: false)

		#expect(view.currentView === photo)
		#expect(photo.transform.a == 0.5)
		#expect(photo.center == CGPoint(x: 150, y: 150))
	}

	@Test func aViewForAnotherIndexPathIsIgnored() {
		let (view, _, _) = makeView(columns: 3)
		view.reloadData()

		let photo = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		view.setView(photo, at: IndexPath(row: 0, section: 2), placeholder: false)

		#expect(view.currentView !== photo)
		#expect(photo.superview == nil)
	}

	@Test func aPlaceholderDoesNotReplaceARealView() {
		let (view, _, _) = makeView(columns: 1)
		view.reloadData()

		let indexPath = IndexPath(row: 0, section: 0)
		let photo = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		view.setView(photo, at: indexPath, placeholder: false)
		let placeholder = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		view.setView(placeholder, at: indexPath, placeholder: true)

		#expect(view.currentView === photo)
	}
}

/// The turning rule of a swipe dismissal. In UIKit, a positive angle turns a view clockwise.
struct DismissTorqueTests {

	@Test func aPullDownToTheRightOfTheCentreTurnsClockwise() {
		let torque = PhotoScrollView.torque(grab: CGPoint(x: 0.5, y: 0), movement: CGPoint(x: 0, y: 100), height: 1000)
		#expect(torque > 0)
	}

	@Test func aPullDownToTheLeftOfTheCentreTurnsAnticlockwise() {
		let torque = PhotoScrollView.torque(grab: CGPoint(x: -0.5, y: 0), movement: CGPoint(x: 0, y: 100), height: 1000)
		#expect(torque < 0)
	}

	@Test func aPushRightAboveTheCentreTurnsClockwise() {
		let torque = PhotoScrollView.torque(grab: CGPoint(x: 0, y: -0.5), movement: CGPoint(x: 100, y: 0), height: 1000)
		#expect(torque > 0)
	}

	@Test func aPullThroughTheCentreDoesNotTurn() {
		let torque = PhotoScrollView.torque(grab: .zero, movement: CGPoint(x: 30, y: 100), height: 1000)
		#expect(torque == 0)
	}

	@Test func theTorqueIsAFractionOfTheHeight() {
		let torque = PhotoScrollView.torque(grab: CGPoint(x: 1, y: 0), movement: CGPoint(x: 0, y: 250), height: 1000)
		#expect(torque == 0.25)
		#expect(PhotoScrollView.torque(grab: CGPoint(x: 1, y: 0), movement: CGPoint(x: 0, y: 250), height: 0) == 0)
	}
}

/// The speed of a swipe dismissal at the release of the finger.
struct ReleaseVelocityTests {

	@Test func aReleaseWithoutAPauseKeepsTheVelocity() {
		let velocity = CGPoint(x: 100, y: 1500)
		#expect(PhotoScrollView.releaseVelocity(velocity, idle: 0) == velocity)
	}

	@Test func aShortPauseReducesTheVelocity() {
		let velocity = PhotoScrollView.releaseVelocity(CGPoint(x: 0, y: 1500), idle: 0.05)
		#expect(velocity.y > 500 && velocity.y < 600)
	}

	@Test func aLongPauseEndsAFlick() {
		// A flick needs 700 points/second.
		let velocity = PhotoScrollView.releaseVelocity(CGPoint(x: 0, y: 3000), idle: 0.3)
		#expect(abs(velocity.y) < 10)
	}
}
