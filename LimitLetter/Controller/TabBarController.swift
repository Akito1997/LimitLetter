//
//  TabBarController.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/24.
//
import UIKit
import Firebase


class TabBarController:UITabBarController{
    
    var user:User?
  
    @IBOutlet weak var myTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTabBar.items?[0].image=UIImage(named: "homeicon")
        myTabBar.items?[1].image=UIImage(named: "eyeicon")
        
        
        myTabBar.items?[0].title="ホーム"
        myTabBar.items?[1].title="見る"
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        conformLoginUser()
//        Homeset()
    }
    private func conformLoginUser(){
        if Auth.auth().currentUser?.uid == nil{
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

    
}
