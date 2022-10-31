import RxCocoa
import RxSwift
import UIKit

class SearchRepositoryViewController: UIViewController {
  @IBOutlet var repositoryNameField: UITextField!
  @IBOutlet var tableView: UITableView!
  
  private let viewModel: SearchRepositoryViewModel
  private let disposeBag = DisposeBag()
  private lazy var refreshControl = UIRefreshControl()
  
  init?(coder: NSCoder, viewModel: SearchRepositoryViewModel) {
    self.viewModel = viewModel
    super.init(coder: coder)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews(viewModel: viewModel)
    bind(viewModel: viewModel)
    bindTransition(viewModel: viewModel)
  }
  
  func setupViews(viewModel: SearchRepositoryViewModel) {
    repositoryNameField.rx.text.subscribe().disposed(by: disposeBag)
    repositoryNameField.rx.controlEvent(.editingDidEnd)
      .compactMap { [weak self] _ in
        self?.repositoryNameField.text
      }
      .bind { text in
        viewModel.onEndInputRepositoryName(text: text)
      }
      .disposed(by: disposeBag)
    
    tableView.register(
      .init(nibName: "RepositoryTableViewCell", bundle: nil),
      forCellReuseIdentifier: "RepositoryTableViewCell"
    )
    tableView.refreshControl = refreshControl
    tableView.rx.itemSelected
      .subscribe { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  func bind(viewModel: SearchRepositoryViewModel) {
    viewModel.loadingRelay.bind { [weak self] isLoading in
      isLoading
        ? self?.tableView.refreshControl?.beginRefreshing()
        : self?.tableView.refreshControl?.endRefreshing()
    }
    .disposed(by: disposeBag)
    
    viewModel.searchResultRelay.bind(to: tableView.rx.items(
      cellIdentifier: "RepositoryTableViewCell",
      cellType: RepositoryTableViewCell.self
    )) { _, item, cell in
      cell.nameLabel.text = item.name
      cell.fullNameLabel.text = item.fullName
    }
    .disposed(by: disposeBag)
  }
  
  func bindTransition(viewModel: SearchRepositoryViewModel) {
    viewModel.transitionSubject.bind { [weak self] transition in
      switch transition {
      case .pop:
        self?.navigationController?.popViewController(animated: true)
      case .error(let error):
        let alert = UIAlertController(title: "エラー", message: error, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        self?.present(alert, animated: true)
      }
    }
    .disposed(by: disposeBag)
  }
}
