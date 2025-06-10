import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showLikeErrorAlert()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let imagesListService = ImagesListService.shared
    private var observer: NSObjectProtocol?
    private var presenter: ImagesListPresenterProtocol!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupPresenter()
    }
    
    private func setupTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func setupPresenter() {
            presenter = ImagesListPresenter()
            presenter.view = self
            presenter.viewDidLoad()
        }
    
    func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModels.Photo {
        return presenter.photoForIndexPath(indexPath)
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
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
        
        imageListCell.delegate = self
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presenter.countOfPhotos() - 1 {
            //            imagesListService.fetchPhotosNextPage()
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
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "stub"),
                options: [.transition(.fade(0.2))]
            )
        }
        
        do {
            let date = try photo.requireCreatedAt()
            cell.dateLabel.text = dateFormatter.string(from: date)
        } catch {
            cell.dateLabel.text = ""
        }
        
        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.heightForRowAt(indexPath: indexPath, tableViewWidth: tableView.bounds.width)
        //        let photo = photos[indexPath.row]
        //        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        //        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        //
        //        guard photo.size.width > 0 else {
        //            return 0
        //        }
        //
        //        let imageWidth = photo.size.width
        //        let scale = imageViewWidth / imageWidth
        //        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        //        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter.photoForIndexPath(indexPath)
        presenter.changeLike(photoId: photo.id, isLike: !photo.isLiked)
        //        let photo = photos[indexPath.row]
        //
        //        UIBlockingProgressHUD.show()
        //        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
        //
        //            guard let self = self else { return }
        //
        //            DispatchQueue.main.async {
        //                switch result {
        //                case .success:
        //                    self.photos = self.imagesListService.photos
        //                    self.tableView.reloadRows(at: [indexPath], with: .none)
        //                    UIBlockingProgressHUD.dismiss()
        //
        //                case .failure(let error):
        //                    UIBlockingProgressHUD.dismiss()
        //                    print("Ошибка при изменении лайка:", error)
        //
        //                    let alert = UIAlertController(
        //                        title: "Что-то пошло не так",
        //                        message: "Не удалось изменить лайк",
        //                        preferredStyle: .alert
        //                    )
        //                    alert.addAction(UIAlertAction(title: "Ок", style: .default))
        //                    self.present(alert, animated: true)
        //                }
        //            }
        //        }
    }
}

