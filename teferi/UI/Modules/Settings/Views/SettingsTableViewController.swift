import UIKit

class SettingsTableViewController: UITableViewController
{
    @IBOutlet weak var submitFeedbackCell: UITableViewCell!
    @IBOutlet weak var ratingCell: UITableViewCell!
    @IBOutlet weak var helpCell: UITableViewCell!
    
    @IBOutlet weak var submitFeedbackLabel: UILabel!
    @IBOutlet weak var rateSuperdayLabel: UILabel!
    @IBOutlet weak var rateSuperdayConvincingMessage: UILabel!
    @IBOutlet weak var helpLabel: UILabel!
    
    var presenter: SettingsPresenter?
    var viewModel: SettingsViewModel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.rowHeight = 45
        
        submitFeedbackLabel.text = L10n.settingsSubmitFeedback
        rateSuperdayLabel.text = L10n.settingsRateUs
        rateSuperdayConvincingMessage.text = L10n.settingsRateUsConvincingMessage
        helpLabel.text = L10n.settingsHelp
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        tableView.addTopShadow()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch cell {
        case submitFeedbackCell:
            viewModel?.composeFeedback()
        case ratingCell:
            presenter?.requestReview()
        case helpCell:
            presenter?.showHelp()
        default:
            break
        }
    }
}
