import UIKit
import RxSwift
import RxDataSources

class GoalViewController: UIViewController
{
    private let disposeBag = DisposeBag()
    private var viewModel : GoalViewModel!
    private var presenter : GoalPresenter!
    
    @IBOutlet private var tableView : UITableView!
    private let dataSource = GoalDataSource()
    private let header = GoalHeader.fromNib()
    
    func inject(presenter: GoalPresenter, viewModel: GoalViewModel)
    {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 78
        tableView.register(UINib.init(nibName: "GoalCell", bundle: Bundle.main), forCellReuseIdentifier: GoalCell.cellIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)

        let footerView = UIView(frame: .zero)
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        
        tableView.addTopShadow()
        
        dataSource.configureCell = constructCell

        createBindings()
    }

    // MARK: Private Methods
    private func createBindings()
    {
        viewModel.goalsObservable
            .map({ [GoalSection(items:$0)] })
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        viewModel.goalsObservable
            .subscribe(onNext: { [unowned self] (goals) in
                self.tableView.tableHeaderView = self.header
                self.header.snp.makeConstraints { make in
                    make.width.equalToSuperview()
                }
                self.header.configure(withGoal: self.viewModel.isCurrentGoal(goals.first) ? goals.first : nil,
                                      message: self.viewModel.message(forGoal: goals.first))
            })
            .addDisposableTo(disposeBag)
        
        header.newGoalButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.presenter.showNewGoalUI()
            })
            .addDisposableTo(self.disposeBag)
    }

    private func constructCell(dataSource: TableViewSectionedDataSource<GoalSection>,
                               tableView: UITableView,
                               indexPath: IndexPath,
                               item:Goal) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: GoalCell.cellIdentifier, for: indexPath) as! GoalCell
        cell.isCurrentGoal = viewModel.isCurrentGoal(item)
        cell.goal = item
        cell.selectionStyle = .none
        return cell
    }
}
