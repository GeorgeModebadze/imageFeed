import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL else { return }
            loadImage(from: imageURL)
        }
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        //        guard let image else { return }
        //        imageView.image = image
        //        imageView.frame.size = image.size
        //        rescaleAndCenterImageInScrollView(image: image)
        if let image = image {
            updateUI(with: image)
        } else if let imageURL = imageURL {
            loadImage(from: imageURL)
        }
    }
    
    private func loadImage(from url: URL) {
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let imageResult):
                DispatchQueue.main.async {
                    self?.imageView.image = imageResult.image
                    self?.imageView.frame.size = imageResult.image.size
                    self?.rescaleAndCenterImageInScrollView(image: imageResult.image)
                }
                
            case .failure:
                self?.showErrorAlert()
            }
        }
    }
    
    func showErrorAlert() {
            let alert = UIAlertController(title: "Что-то пошло не так",
                                          message: "Не удалось войти в систему",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            
            present(alert, animated: true)
        }
    
    private func updateUI(with image: UIImage) {
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
