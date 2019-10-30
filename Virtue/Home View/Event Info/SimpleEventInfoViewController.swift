//
//  SimpleEventInfoViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 9/3/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class SimpleEventInfoViewController: UIViewController{
        
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var creatorView: UIView!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var creatorButton: UIButton!
    
    var viewPageViewController: UIPageViewController!
    var eventViewController: EventViewController!
    var creatorViewController: CreatorViewController!
    var viewControllerArray: [UIViewController]!
    var creatorInfo: UserInfo!
    var eventInfo: EventInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewPageViewController") as! UIPageViewController
        eventViewController = self.storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        creatorViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreatorViewController")as! CreatorViewController
        
        eventViewController.eventInfo = self.eventInfo
        eventViewController.creatorInfo = self.creatorInfo
        creatorViewController.eventInfo = self.eventInfo
        creatorViewController.creatorInfo = self.creatorInfo
        
        viewPageViewController.dataSource = self
        viewPageViewController.delegate = self
        viewControllerArray = [eventViewController, creatorViewController]
        
        viewPageViewController.setViewControllers([eventViewController],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)
        
        self.addChildViewController(viewPageViewController)
        self.view.addSubview(viewPageViewController.view)
        viewPageViewController.didMove(toParentViewController: self)
        
        eventButton.isEnabled = false
        creatorButton.isEnabled = true
        eventView.isHidden = false
        creatorView.isHidden = true
        eventButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17.0)
    }
    
    @IBAction func creatorPressed(_ sender: Any) {
        viewPageViewController.setViewControllers([creatorViewController], direction: .forward, animated: true, completion: nil)
        
        eventButton.isEnabled = true
        creatorButton.isEnabled = false
        eventButton.titleLabel!.font = UIFont.systemFont(ofSize: 17.0)
        creatorButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17.0)
        eventView.isHidden = true
        creatorView.isHidden = false
    }
    @IBAction func eventPressed(_ sender: Any) {
        viewPageViewController.setViewControllers([eventViewController], direction: .reverse, animated: true, completion: nil)
        
        eventButton.isEnabled = false
        creatorButton.isEnabled = true
        eventButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 17.0)
        creatorButton.titleLabel!.font = UIFont.systemFont(ofSize: 17.0)
        eventView.isHidden = false
        creatorView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SimpleEventInfoViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
            
            if previousViewControllers == [eventViewController]{
                creatorPressed(creatorButton)
            } else {
                eventPressed(eventButton)
            }
        }
    }
}
