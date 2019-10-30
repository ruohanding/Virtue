//
//  SignUpViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 10/19/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    var signUpPageViewController: UIPageViewController!
    var phoneViewController: UIViewController!
    var emailViewController: UIViewController!
    var viewControllerArray: [UIViewController]!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phoneView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpPageViewController") as! UIPageViewController
        
        phoneViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhoneViewController")
        emailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountEmailViewController")
        
        // sets the pageViewController
        signUpPageViewController.dataSource = self
        signUpPageViewController.delegate = self
        signUpPageViewController.view.frame = pageView.frame
        viewControllerArray = [phoneViewController, emailViewController]
        
        signUpPageViewController.setViewControllers([phoneViewController],
                                                   direction: .forward,
                                                   animated: true,
                                                   completion: nil)
        phoneButton.isEnabled = false
        emailView.isHidden = true
        phoneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        self.addChildViewController(signUpPageViewController)
        self.view.addSubview(signUpPageViewController.view)
        signUpPageViewController.didMove(toParentViewController: self)
    }

    @IBAction func phonePressed(_ sender: Any) {
        
        signUpPageViewController.setViewControllers([phoneViewController], direction: .reverse, animated: true, completion: nil)
        
        phoneButton.isEnabled = false
        emailButton.isEnabled = true
        phoneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 20.0)
        emailButton.titleLabel!.font = UIFont.systemFont(ofSize: 20.0)
        phoneView.isHidden = false
        emailView.isHidden = true
    }
    @IBAction func emailPressed(_ sender: Any) {
        
        signUpPageViewController.setViewControllers([emailViewController], direction: .forward, animated: true, completion: nil)
        
        phoneButton.isEnabled = true
        emailButton.isEnabled = false
        phoneButton.titleLabel!.font = UIFont.systemFont(ofSize: 20.0)
        emailButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 20.0)
        phoneView.isHidden = true
        emailView.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SignUpViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllerArray.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let viewControllersCount = viewControllerArray.count
        
        guard viewControllersCount != nextIndex else {
            return nil
        }
        
        guard viewControllersCount > nextIndex else {
            return nil
        }
        
        return viewControllerArray[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllerArray.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllerArray.count > previousIndex else {
            return nil
        }
        
        return viewControllerArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // if the transition was actually made
        if completed {
            
            if previousViewControllers == [phoneViewController]{
                // this is for email
                self.emailPressed(emailButton)
            } else {
                // this is for phone
                self.phonePressed(phoneButton)
            }
        }
    }
}



