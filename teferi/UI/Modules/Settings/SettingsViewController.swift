import Foundation
import UIKit

class SettingsViewController: UITableViewController
{
    //MARK: Essentials
    fileprivate var viewModel: SettingsViewModel!
    fileprivate var presenter: SettingsPresenter!
    
    //MARK: Outlets
    @IBOutlet weak var submitFeedbackCell: UITableViewCell!
    @IBOutlet weak var ratingCell: UITableViewCell!
    @IBOutlet weak var helpCell: UITableViewCell!
    
    @IBOutlet weak var submitFeedbackLabel: UILabel!
    @IBOutlet weak var rateSuperdayLabel: UILabel!
    @IBOutlet weak var rateSuperdayConvincingMessage: UILabel!
    @IBOutlet weak var helpLabel: UILabel!
    
    //MARK: Public Methods
    func inject(presenter : SettingsPresenter, viewModel: SettingsViewModel)
    {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    //MARK: View Controller Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureTableView()
        configureLocalization()
    }
    
    //MARK: Private Methods
    private func configureLocalization()
    {
        submitFeedbackLabel.text = L10n.settingsSubmitFeedback
        rateSuperdayLabel.text = L10n.settingsRateUs
        rateSuperdayConvincingMessage.text = L10n.settingsRateUsConvincingMessage
        helpLabel.text = L10n.settingsHelp
    }
    
    private func configureTableView()
    {
        tableView.tableFooterView = UIView()
    }
}

extension SettingsViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath) == submitFeedbackCell {
            self.viewModel.composeFeedback()
        }
        
        if tableView.cellForRow(at: indexPath) == ratingCell {
            self.viewModel.requestReview()
        }
        
        if tableView.cellForRow(at: indexPath) == helpCell {
            self.presenter.openHelp()
        }
    }
}
