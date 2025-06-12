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
    var presenter: ImagesListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    
    private func setupTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModels.Photo {
        return presenter?.photoForIndexPath(indexPath) ?? PhotoModels.Photo(
                    id: "",
                    size: CGSize(),
                    createdAt: nil,
                    welcomeDescription: nil,
                    thumbImageURL: "",
                    largeImageURL: "",
                    isLiked: false
                )
    }

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
            
            let photo = presenter?.photoForIndexPath(indexPath)
            viewController.imageURL = URL(string: photo?.largeImageURL ?? "")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.countOfPhotos() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        if let photo = presenter?.photoForIndexPath(indexPath) {
            imageListCell.setIsLiked(photo.isLiked)
        }
        imageListCell.delegate = self
        
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let testMode = ProcessInfo.processInfo.arguments.contains("testMode")
        
        if !testMode, let count = presenter?.countOfPhotos(), indexPath.row == count - 1 {
            presenter?.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photoForIndexPath(indexPath) else { return }
        
        cell.cellImage.image = UIImage(named: "stub")
        cell.cellImage.kf.cancelDownloadTask()
        cell.cellImage.kf.indicatorType = .activity
        
        if let url = presenter?.thumbImageURL(for: photo) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "stub"),
                options: [.transition(.fade(0.2))]
            )
        }
        
        cell.dateLabel.text = presenter?.formatPhotoDate(photo)
        
        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter?.heightForRowAt(indexPath: indexPath, tableViewWidth: tableView.bounds.width) ?? 200
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = presenter?.photoForIndexPath(indexPath) else { return }
        
        presenter?.changeLike(photoId: photo.id, isLike: !photo.isLiked)
        
    }
}

