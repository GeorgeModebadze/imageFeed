import UIKit

final class TabBarController: UITabBarController {
       override func awakeFromNib() {
           super.awakeFromNib()
           let storyboard = UIStoryboard(name: "Main", bundle: .main)
           let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
           
           let imagesListPresenter = ImagesListPresenter()
           imagesListViewController?.presenter = imagesListPresenter
           imagesListPresenter.view = imagesListViewController
           
           let profileViewController = ProfileViewController()
           let profilePresenter = ProfilePresenter()
           profileViewController.presenter = profilePresenter
           profilePresenter.view = profileViewController
           
           profileViewController.tabBarItem = UITabBarItem(
               title: "",
               image: UIImage(named: "tab_profile_active"),
               selectedImage: nil
           )
           
           
//           self.viewControllers = [imagesListViewController, profileViewController]
           self.viewControllers = [imagesListViewController, profileViewController].compactMap { $0 }
       }
   }

