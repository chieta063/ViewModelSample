import Moya
import RxCocoa
import RxMoya
import RxSwift
import UIKit

class MainViewController: UIViewController {
  @IBOutlet var moveSearchRepositoryButton: UIBarButtonItem!
  @IBOutlet var userNameField: UITextField!
  @IBOutlet var tableView: UITableView!

  private let viewModel: MainViewModel
  private let disposeBag = DisposeBag()

  private lazy var refreshControl = UIRefreshControl()

  init?(coder: NSCoder, viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init(coder: coder)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews(viewModel: viewModel)
    bind(viewModel: viewModel)
    bindTransition(viewModel: viewModel)
  }

  private func setupViews(viewModel: MainViewModel) {
    tableView.register(
      .init(nibName: "RepositoryTableViewCell", bundle: nil),
      forCellReuseIdentifier: "RepositoryTableViewCell"
    )
    tableView.refreshControl = refreshControl

    tableView.rx.itemSelected.subscribe { [weak self] indexPath in
      self?.tableView.deselectRow(at: indexPath, animated: true)
    }
    .disposed(by: disposeBag)

    moveSearchRepositoryButton.rx.tap.bind { _ in
      viewModel.onTapMoveSearchRepositoryButton()
    }
    .disposed(by: disposeBag)

    userNameField.rx.text.subscribe().disposed(by: disposeBag)
    userNameField.rx.controlEvent(.editingDidEnd).compactMap { [weak self] _ in
      self?.userNameField.text
    }.subscribe { userName in
      viewModel.onEndInputUserName(text: userName)
    }
    .disposed(by: disposeBag)
  }

  private func registerEvent(viewModel _: MainViewModel) {}

  private func bind(viewModel: MainViewModel) {
    viewModel.loadingSubject.bind { [weak self] isLoading in
      isLoading
        ? self?.tableView.refreshControl?.beginRefreshing()
        : self?.tableView.refreshControl?.endRefreshing()
    }.disposed(by: disposeBag)
    
    viewModel.repositoriesSubject
      .bind(to: tableView.rx.items(
        cellIdentifier: "RepositoryTableViewCell",
        cellType: RepositoryTableViewCell.self
      )) { _, item, cell in
        cell.nameLabel.text = item.name
        cell.fullNameLabel.text = item.fullName
      }
      .disposed(by: disposeBag)
  }

  private func bindTransition(viewModel: MainViewModel) {
    viewModel.transitionSubject.bind { [weak self] transition in
      switch transition {
      case .searchRepository:
        let storyboard = UIStoryboard(name: "SearchRepository", bundle: nil)
        let vc = storyboard.instantiateInitialViewController { coder in
          SearchRepositoryViewController(coder: coder, viewModel: .init(githubAPI: GitHubAPIImpl()))
        }!
        self?.navigationController?.pushViewController(vc, animated: true)
      case let .error(error):
        let alert = UIAlertController(title: "エラー", message: error, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        self?.present(alert, animated: true)
      }
    }
    .disposed(by: disposeBag)
  }
}
