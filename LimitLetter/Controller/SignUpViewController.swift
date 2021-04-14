//
//  LoginViewController.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/18.
//

import UIKit
import Firebase
import PKHUD
import FirebaseStorage

class SignUpViewController: UIViewController{
    

    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        
        if let image=self.profileImageButton.imageView?.image {
            
            guard let uploading=image.jpegData(compressionQuality: 0.3) else {return}
            
            let fileName=NSUUID().uuidString
            let storageRef=Storage.storage().reference().child("profile_image").child(fileName)
            storageRef.putData(uploading,metadata: nil){(matedata,err) in
                if let err=err{
                    print("firestorageへの保存に失敗しました\(err)")
                    return
                }
                print("firestorageへの保存をしました")
                storageRef.downloadURL{(url,err) in
                    if let err=err{
                        print("firestoreからのダウンロードに失敗しました\(err)")
                        return
                    }
                    guard let urlString=url?.absoluteString else {return}
                    self.handleAuthtoFirebase(profileImageURL: urlString)
                    
                }
            }
        }else{
            self.handleAuthtoFirebase(profileImageURL: "https://firebasestorage.googleapis.com/v0/b/limitletter.appspot.com/o/profile_images%2Fdefault.jpeg?alt=media&token=13bfbe10-a0fe-449f-8dea-ca276a9ca2fe")
        }
    }
    
    
    @IBAction func noAccountButton(_ sender: Any) {
        let storybord=UIStoryboard(name: "Login", bundle: nil)
        let LoginViewController=storybord.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        navigationController?.pushViewController(LoginViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //registerボタンのこと
        registerButton.isEnabled=false
        registerButton.layer.cornerRadius=10
        registerButton.backgroundColor=UIColor.rgb(red: 255, green: 221, blue: 187)
        //プロフィール画像のこと
        profileImageButton.layer.cornerRadius=70
        profileImageButton.layer.borderWidth=1
        profileImageButton.layer.borderColor=UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)

        //デリゲートの設定
        emailTextField.delegate=self
        passwordTextField.delegate=self
        usernameTextField.delegate=self

        NotificationCenter.default.addObserver(self, selector: #selector(showKeybord), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeybord), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden=true
    }
    @objc private func tappedProfileImageButton(){
        let imagePickerController=UIImagePickerController()
        imagePickerController.delegate=self
        imagePickerController.allowsEditing=true
        
        self.present(imagePickerController,animated: true,completion: nil)
    }
    
    private func handleAuthtoFirebase(profileImageURL:String){
        HUD.show(.progress,onView: view)
        guard let email=emailTextField.text else {return}
        guard let password=passwordTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (res,err) in
            if let err=err{
                print("認証情報の保存に失敗しました\(err)")
                HUD.hide{(_) in
                    HUD.flash(.error,delay: 1)
                }
                return
            }
            self.addUserInfoFirestore(email: email, profileImageURL: profileImageURL)
        }
        
    }
    
    private func addUserInfoFirestore(email:String,profileImageURL:String){
        guard let uid=Auth.auth().currentUser?.uid else {return}
        guard let name=self.usernameTextField.text else {return}
        
        let docDate=["email":email,"name":name,"createdAt":Timestamp(),"profileImageURL":profileImageURL] as [String : Any]
        let userRef=Firestore.firestore().collection("users").document(uid)
        userRef.setData(docDate) {(err) in
            if let err=err{
                print("Firebaseに失敗しました\(err)")
                HUD.hide{(_) in
                    HUD.flash(.error,delay: 1)
                }
                return
            }
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
        let storybord=UIStoryboard(name: "Welcome", bundle: nil)
        let WelcomeViewController=storybord.instantiateViewController(identifier: "WelcomeViewController") as! WelcomeViewcontroller
        WelcomeViewController.user=user
        WelcomeViewController.modalPresentationStyle = .fullScreen
        self.present(WelcomeViewController, animated: true, completion: nil)
    }
    
    @objc func showKeybord(notification:Notification){
        let keybordFrame=(notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keybordMinY=keybordFrame?.minY else {return}
        let registerButtonMaxY=registerButton.frame.maxY
        let distance=registerButtonMaxY-keybordMinY+20
        
        let transform=CGAffineTransform(translationX:0,y:-distance)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform=transform
        })
        
    }
    @objc func hideKeybord(notification :Notification){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SignUpViewController:UITextFieldDelegate{
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailisEmpty=emailTextField.text?.isEmpty ?? true
        let passworisEmpty=passwordTextField.text?.isEmpty ?? true
        let usernameisEmpty=usernameTextField.text?.isEmpty ?? true
        
        if emailisEmpty || passworisEmpty || usernameisEmpty{
            registerButton.isEnabled=false
            registerButton.backgroundColor=UIColor.rgb(red: 255, green: 221, blue: 187)
        }else{
            registerButton.isEnabled=true
            registerButton.backgroundColor=UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
   
}
extension SignUpViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage=info[.editedImage] as? UIImage{
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.originalImage] as? UIImage{
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill

        profileImageButton.clipsToBounds=true
        
        dismiss(animated: true, completion: nil)
    }
}
