//
//  homeViewcontroller.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/19.
//
import Foundation
import UIKit
import Firebase

class WelcomeViewcontroller:UIViewController{
    
    var user:User?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user=user{
        nameLabel.text=user.name+"さんようこそ"
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        conformLoginUser()
    }
   
    private func conformLoginUser(){
        if Auth.auth().currentUser?.uid == nil || user==nil{
            presentToMain()
        }
    }
    
    private func presentToMain(){
        let storybord=UIStoryboard(name: "Main", bundle: nil)
        let SignUpViewController=storybord.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        let navController=UINavigationController(rootViewController: SignUpViewController)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        let storybord=UIStoryboard(name: "Home", bundle: nil)
        let TabBarController=storybord.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        
        let UINavigationController = TabBarController.viewControllers?[0] as! HomeViewController
        UINavigationController.user=self.user
        TabBarController.user=self.user
        TabBarController.selectedViewController = UINavigationController
        TabBarController.modalTransitionStyle = .flipHorizontal
        TabBarController.modalPresentationStyle = .fullScreen
       
        self.present(TabBarController, animated: true, completion: nil)
    }

}

