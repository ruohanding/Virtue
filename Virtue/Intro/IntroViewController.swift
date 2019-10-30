//
//  IntroViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 4/13/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn

class IntroViewController: UIViewController { //GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var pageController: UIPageControl!
    //@IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    //var pvc : UIPageViewController!
    var pageImages: NSArray!
    var dataRef: DatabaseReference!
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.endLoading()
        self.navigationController?.isNavigationBarHidden = true
        // hides the navigation bar
        
        // makes everything perty
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        // unhides the navigation bar
    }
    
    override func viewDidLoad() {
        
        //self.pageImages = NSArray(objects: "0", "1", "2")
        // all the images
        
        //single image
        //self.pageImages = NSArray(objects: "Intro Image")
        
        // buttons
        self.createAccountButton.layer.cornerRadius = 6
        createAccountButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //self.pvc = self.storyboard?.instantiateViewController(withIdentifier: "IntroPageViewController") as! UIPageViewController
        // creates a new intropvc through the storyboard id
        
        /*self.pvc.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as IntroContentViewController
        // creates a blank/starting view controller with the index of zero.
        
        let viewControllers = NSArray(object: startVC)
        
        self.pvc.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height + 40)
        
        self.pvc.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(pvc)
        self.view.addSubview(pvc.view)
        self.pvc.didMove(toParentViewController: self)
        //adds pvc as a subview
        
        self.view.bringSubview(toFront: self.pageController)
        self.view.bringSubview(toFront: self.createAccountButton)
        self.view.bringSubview(toFront: self.signInButton)
        //self.view.bringSubview(toFront: self.googleSignInButton)
        // puts the dots and button before the images
        */
        
        /*GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self*/
        
        dataRef = Database.database().reference()
    }
    
    /*func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // shows the little gray loading circle
        self.startLoading()
        self.view.endEditing(true)
        if let googleError = error {
            
            print(googleError)
            return
        }
        
        // sings in with google provided credientials
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if user != nil {
                let userID = user!.uid
                self.dataRef.child("users").child(userID).observe(.value, with: { (snapshot) in
                    
                    // checks to see whether it is necessary to make the user pick a userType
                    let values = snapshot.value as? NSDictionary
                    
                    let userType = values?["userType"] as? String ?? ""
                    
                    // if there is a usetype then it is no longer necessary to segue to the next view
                    if userType != "" {
                        
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        
                        self.performSegue(withIdentifier: "nameSegue", sender: self)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                // stops the loading
                self.endLoading()
                
            } else {
                
                self.endLoading()
                if let accountError = error?.localizedDescription {
                    
                    print(accountError)
                } else {
                    
                    print("Unknown create account error")
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
       // something about disconnect
        if let googleError = error {
            
            print(googleError)
            return
        }
        
        try! Auth.auth().signOut()
    }*/
    
    /*func viewControllerAtIndex(_ index: Int) -> IntroContentViewController{
        
        let vc: IntroContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "IntroContentViewController") as! IntroContentViewController
        
        
        
        vc.imageFile = self.pageImages[index]as! String
        
        vc.pageIndex = index
        
        return vc
        // vc is a contenct view controller that is set an image by the index
        
    }*/
    
    func startLoading() {
        // creats an activity indicator and sets it to the middle of the screen and makes it grey
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
        
        activityIndicator.startAnimating()
        // ignores all evens
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func endLoading() {
        
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

/*extension IntroViewController: UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! IntroContentViewController
        
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound){
            
            self.pageController.currentPage = index
            return nil
            
        }
        
        index -= 1
        
        self.pageController.currentPage = index + 1
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! IntroContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound){
            self.pageController.currentPage = index
            return nil
        }
        
        index += 1
        
        self.pageController.currentPage = index - 1
        
        if (index == self.pageImages.count){
            
            self.pageController.currentPage = index - 1
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        // to be honest IDK what these two methods do but they WORK.
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}*/
