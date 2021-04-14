//
//  LoginViewController.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/20.
//

import UIKit
import Firebase
import PKHUD

class LoginViewController:UIViewController{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBAction func tappednoAccountButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedLoginButton(_ sender: Any) {
        HUD.show(.progress,onView: self.view)
        guard let email=emailTextField.text else {return}
        guard let password=passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password){(res,err) in
            if let err=err{
                print("\(err)")
                return
            }
            guard let uid=Auth.auth().currentUser?.uid else {return}
            let userRef=Firestore.firestore().collection("users").document(uid)
            userRef.getDocument { (snapshot,err) in
                if let err=err{
                    print("ユーザーの情報を所得に失敗しました\(err)")
                    HUD.hide{(_) in
                        HUD.flash(.error,delay: 1)
                    }
                    
                    return
                }
                guard let data=snapshot?.data() else {return}
                let user=User.init(dic: data)
                
                HUD.hide{(_) in
                    HUD.flash(.success,onView: self.view,delay: 1){(_) in
                        self.presentTohomeViewController(user: user)
                    }
                }
            }
            
        }

        
    }
    private func presentTohomeViewController(user:User){
        let storybord=UIStoryboard(name: "Home", bundle: nil)
        let homeViewController=storybord.instantiateViewController(identifier: "TabBarController") as! TabBarController
        homeViewController.user=user
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginButton.isEnabled=false
        LoginButton.layer.cornerRadius=10
        LoginButton.backgroundColor=UIColor.rgb(red: 255, green: 221, blue: 187)
        
        emailTextField.delegate=self
        passwordTextField.delegate=self

        
    }
}
extension LoginViewController:UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailisEmpty=emailTextField.text?.isEmpty ?? true
        let passworisEmpty=passwordTextField.text?.isEmpty ?? true
        
        if emailisEmpty || passworisEmpty {
            LoginButton.isEnabled=false
            LoginButton.backgroundColor=UIColor.rgb(red: 255, green: 221, blue: 187)
        }else{
            LoginButton.isEnabled=true
            LoginButton.backgroundColor=UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
