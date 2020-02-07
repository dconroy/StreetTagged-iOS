import UIKit
import GetStream
import GetStreamActivityFeed

class StreamViewController: FlatFeedViewController<GetStreamActivityFeed.Activity> {

    let textToolBar = TextToolBar.make()

    override func viewDidLoad() {
        if let feedId = FeedId(feedSlug: "timeline") {
            let timelineFlatFeed = Client.shared.flatFeed(feedId)
            presenter = FlatFeedPresenter<GetStreamActivityFeed.Activity>(flatFeed: timelineFlatFeed,
                                                                          reactionTypes: [.likes, .comments])
        }
        super.viewDidLoad()
        setupTextToolBar()
       //subscribeForUpdates()
    }

    func setupTextToolBar() {
        textToolBar.addToSuperview(view, placeholderText: "Share something...")
        // Enable URL unfurling.
        textToolBar.linksDetectorEnabled = true
        // Enable image picker.
        textToolBar.enableImagePicking(with: self)
        textToolBar.sendButton.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
    }

    @objc func save(_ sender: UIButton) {
        // Hide the keyboard.
        view.endEditing(true)

        if textToolBar.isValidContent, let presenter = presenter {
            textToolBar.addActivity(to: presenter.flatFeed) { result in
                print(result) // It will print the added activity or error.
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let detailViewController = DetailViewController<GetStreamActivityFeed.Activity>()
            detailViewController.activityPresenter = activityPresenter(in: indexPath.section)
            detailViewController.sections = [.activity, .comments]
            present(UINavigationController(rootViewController: detailViewController), animated: true)
        } else {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
}
