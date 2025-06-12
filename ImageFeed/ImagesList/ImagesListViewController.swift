import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showLikeErrorAlert()
    func reloadRow(at indexPath: IndexPath)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let imagesListService = ImagesListService.shared
    private var observer: NSObjectProtocol?
    var presenter: ImagesListPresenterProtocol!
    
//    private lazy var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        formatter.timeStyle = .none
//        formatter.locale = Locale(identifier: "ru_RU")
//        return formatter
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
//        setupPresenter()
        presenter?.viewDidLoad()
    }
    
    
    private func setupTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
//    private func setupPresenter() {
//            presenter = ImagesListPresenter()
//            presenter.view = self
//            presenter.viewDidLoad()
//        }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModels.Photo {
        return presenter.photoForIndexPath(indexPath)
    }
    
//    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
//        //        if oldCount != newCount {
//        //            DispatchQueue.main.async {
//        //                self.tableView.performBatchUpdates {
//        //                    if newCount > oldCount {
//        //                        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
//        //                        self.tableView.insertRows(at: indexPaths, with: .automatic)
//        //                    } else {
//        //                        let indexPaths = (newCount..<oldCount).map { IndexPath(row: $0, section: 0) }
//        //                        self.tableView.deleteRows(at: indexPaths, with: .automatic)
//        //                    }
//        //                }
//        //            }
//        tableView.performBatchUpdates {
//            let indexPaths = (oldCount..<newCount).map { i in
//                IndexPath(row: i, section: 0)
//            }
//            tableView.insertRows(at: indexPaths, with: .automatic)
//        } completion: { _ in }
//    }
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard oldCount != newCount else { return }
        
        DispatchQueue.main.async {
            self.tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    
    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось изменить лайк",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = presenter.photoForIndexPath(indexPath)
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        photos.count
        presenter.countOfPhotos()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        let photo = presenter.photoForIndexPath(indexPath)
        imageListCell.delegate = self
        
        imageListCell.setIsLiked(photo.isLiked)
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        if indexPath.row == presenter.countOfPhotos() - 1 {
        //            presenter.fetchPhotosNextPage()
        //        }
        // Для UI тестов
        let testMode = ProcessInfo.processInfo.arguments.contains("testMode")
        
        if !testMode && indexPath.row == presenter.countOfPhotos() - 1 {
            presenter.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photoForIndexPath(indexPath)
        
        cell.cellImage.image = UIImage(named: "stub")
        cell.cellImage.kf.cancelDownloadTask()
        cell.cellImage.kf.indicatorType = .activity
        
        if let url = presenter.thumbImageURL(for: photo) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "stub"),
                options: [.transition(.fade(0.2))]
            )
        }
        
        cell.dateLabel.text = presenter.formatPhotoDate(photo)
        
//        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.heightForRowAt(indexPath: indexPath, tableViewWidth: tableView.bounds.width)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter.photoForIndexPath(indexPath)
        presenter.changeLike(photoId: photo.id, isLike: !photo.isLiked)
        
    }
}

