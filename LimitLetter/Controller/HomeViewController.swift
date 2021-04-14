//
//  HomeViewController.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/22.
//

import UIKit
import Firebase
import PKHUD
import FirebaseStorage
import Nuke


class HomeViewController:UIViewController,UIGestureRecognizerDelegate{
    
 
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var leaveTime: UILabel!
    @IBOutlet weak var leaveMozi: UILabel!
    @IBOutlet weak var firework: UIImageView!
    
    var user:User?
    var timer=Timer()
    var defaultNum=0
    var moziNum=0
    var saminute=0
    var sasecond=0
    var second=0
    var minute=0
    var first=0
    var name=""
    var Info_minute=0
    var Info_second=0

    
    @objc func tappedButton(_ sender: Any) {
        
        let storybord=UIStoryboard(name: "Write", bundle: nil)
        let nextVC=storybord.instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
        nextVC.moziCount=self.moziNum
        nextVC.presentationController?.delegate = self
        self.present(nextVC, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        //アプリがアクティブになったとき
        notificationCenter.addObserver(
            self,
            selector: #selector(self.start),
            name:UIApplication.didBecomeActiveNotification,
            object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.finish), name: UIApplication.didEnterBackgroundNotification, object: nil)

        let writeButton=BottomButton(type: .custom)

        writeButton.translatesAutoresizingMaskIntoConstraints=false
        writeButton.addTarget(self,action: #selector(self.tappedButton(_ :)),for: .touchUpInside)

        writeButton.setImage(UIImage(named: "write"), for: .normal)
        // 角丸で親しみやすく
        writeButton.layer.cornerRadius=15
        writeButton.backgroundColor=#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        writeButton.layer.shadowOpacity = 0.5
        writeButton.layer.shadowRadius = 10
        writeButton.layer.shadowColor = UIColor.black.cgColor
        writeButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        view.addSubview(writeButton)
        
        [writeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: 200),
         writeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        writeButton.widthAnchor.constraint(equalToConstant: 200),
        writeButton.heightAnchor.constraint(equalToConstant: 50)].forEach {$0?.isActive=true}
        
        let url=UserDefaults.standard.string(forKey: "userImageURL")
        let userName=UserDefaults.standard.string(forKey: "userName")

        if let url=url{
            if let userName=userName{
                let userimage=getImageByUrl(url: url)
                profileImageButton.setImage(userimage, for: .normal)
                profileImageButton.setTitle("", for: .normal)
                profileImageButton.imageView?.contentMode = .scaleAspectFill
                profileImageButton.contentHorizontalAlignment = .fill
                profileImageButton.contentVerticalAlignment = .fill
                profileImageButton.clipsToBounds=true
                //ユーザーネームのセット
                self.userName.text=userName
                self.userName.textAlignment = .center
                
                //プロフィ-ルボタンのUI
                profileImageButton.layer.cornerRadius=50
                profileImageButton.layer.borderWidth=1
                profileImageButton.layer.borderColor=UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
                profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
            }else{
                userInfoset()
            }
        }else{
            userInfoset()
        }
        moziSet(first: true)
        let longPressGesture = UILongPressGestureRecognizer(target: self,action: #selector(self.longPress(_:)))
        
        longPressGesture.delegate = self
        leaveMozi.isUserInteractionEnabled=true
        leaveMozi.addGestureRecognizer(longPressGesture)
        leaveTime.isHidden=true
    }
    @objc private func start(){
      
        if !timer.isValid{
            moziSet(first: false)
        }
    }
    @objc private func finish(){
        timer.invalidate()
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
              if sender.state == .began {
                  // 開始は認知される
                leaveTime.isHidden=false
              }
              else if sender.state == .ended {
                leaveTime.isHidden=true
              }
       }
    private func userInfoset(){
        guard let uid=Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument{ [self](snapshots,err) in
            if let err=err{
                print("情報の所得に失敗しました\(err)")
            }
            guard let dic=snapshots?.data() else {return}
            self.user=User(dic: dic)
            guard let url=self.user?.profileImageUrl else {return}
            UserDefaults.standard.set(url, forKey: "userImageURL")
            UserDefaults.standard.set(self.user?.name, forKey: "userName")
            let userimage=getImageByUrl(url: url)
            profileImageButton.setImage(userimage, for: .normal)
            profileImageButton.setTitle("", for: .normal)
            profileImageButton.imageView?.contentMode = .scaleAspectFill
            profileImageButton.contentHorizontalAlignment = .fill
            profileImageButton.contentVerticalAlignment = .fill
            profileImageButton.clipsToBounds=true
            //ユーザーネームのセット
            userName.text=self.user?.name
            userName.textAlignment = .center
         
            //プロフィ-ルボタンのUI
            profileImageButton.layer.cornerRadius=50
            profileImageButton.layer.borderWidth=1
            profileImageButton.layer.borderColor=UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
            profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
            
        }
    }
    private func moziSet(first:Bool){
        self.firework.image=UIImage(named: "moziNumback")
        self.moziNum=UserDefaults.standard.integer(forKey: "moziNum")
        let dt = Date()
        if let old_time=load(key: "old_time"){
            let calendar=Calendar(identifier: .japanese)
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: old_time,to: dt)
            
            let year=components.year ?? 0
            let month=components.month ?? 0
            let day=components.day ?? 0
            let hour=components.hour ?? 0
            let minute=components.minute ?? 0
            let second=components.second ?? 0
            defaultNum=year*8760+month*730+day*24+hour
            saminute=minute
            sasecond=second
            self.moziNum=defaultNum+self.moziNum
            self.leaveMozi.text = String(format: "%02d", self.moziNum)
            self.leaveMozi.text=String(self.moziNum)
            if first{
                self.second=59-sasecond%60
                self.minute=59-saminute%60
            }else{
                self.second=UserDefaults.standard.integer(forKey: "second")-sasecond%60
                self.minute=UserDefaults.standard.integer(forKey: "minute")-saminute%60
            }
            
            UserDefaults.standard.set(self.moziNum, forKey: "moziNum")
            UserDefaults.standard.set(dt, forKey: "old_time")

        }else{
            self.leaveMozi.text=String(self.moziNum)
            UserDefaults.standard.set(dt, forKey: "old_time")

            
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            
            self.second=self.second-1
            if self.second<=0{
                self.minute=self.minute-1
                self.second=59
                UserDefaults.standard.set(self.minute, forKey: "minute")
                if self.minute<=0{
                    self.minute=59
                    self.moziNum=self.moziNum+1
                    UserDefaults.standard.set(self.moziNum, forKey: "moziNum")
                }
            }
            UserDefaults.standard.set(self.second, forKey: "second")
            UserDefaults.standard.set(self.minute, forKey: "minute")
            self.leaveTime.text="1文字追加まで"+String(format: "%02d", self.minute)+":"+String(format: "%02d", self.second)
            self.leaveMozi.text=String(self.moziNum)
        })
        
    }
    private func load(key: String) -> Date? {
        let value = UserDefaults.standard.object(forKey: key)
        guard let date = value as? Date else {
            return nil
        }
        return date
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !timer.isValid{
            first=0
            moziSet(first: false)
        }
        navigationController?.navigationBar.isHidden=true

    }
    

   
    @objc private func tappedProfileImageButton(){
        let imagePickerController=UIImagePickerController()
        imagePickerController.delegate=self
        imagePickerController.allowsEditing=true
        
        self.present(imagePickerController,animated: true,completion: nil)
    }
   
    func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
    
    private func updateUserInfoFirestore(email:String){
        
        guard let image=profileImageButton.imageView?.image else {return}
        guard let uploading=image.jpegData(compressionQuality: 0.3) else {return}
        guard let uid=Auth.auth().currentUser?.uid else {return}
        let fileName=uid+".jpg"
        let storageRef=Storage.storage().reference().child("profile_images").child(fileName)
        
        storageRef.putData(uploading,metadata: nil){(matedata,err) in
            if let err=err{
                print("firestorageへの保存に失敗しました\(err)")
                return
            }
            storageRef.downloadURL{(url,err) in
                if let err=err{
                    print("firestoreからのダウンロードに失敗しました\(err)")
                    return
                }
                guard let urlString=url?.absoluteString else {return}
                self.urlupdate(urlString: urlString)
                
            }
        }
    }
    private func urlupdate(urlString:String){
        guard let uid=Auth.auth().currentUser?.uid else {return}
        let userRef=Firestore.firestore().collection("users").document(uid)
        userRef.updateData(["profileImageURL":urlString]) {(err) in
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
                self.user=User.init(dic: data)
                UserDefaults.standard.set(self.user?.profileImageUrl, forKey: "userImageURL")
                HUD.hide{(_) in
                    HUD.flash(.success,onView: self.view,delay: 1){(_) in
                    }
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let old_dt=Date()
        UserDefaults.standard.set(old_dt, forKey: "old_time")
        timer.invalidate()
    }
}

extension HomeViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
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
        updateUserInfoFirestore(email: user?.email ?? "")
        dismiss(animated: true, completion: nil)
    }
}
extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.moziNum=UserDefaults.standard.integer(forKey: "moziNum")
        leaveMozi.text=String(self.moziNum)
    }
}

class BottomButton:UIButton{
    
    override var isHighlighted: Bool{
        didSet{
            if isHighlighted{
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: []) {
                    
                    self.transform = .init(scaleX: 0.85, y: 0.85)
                    self.layoutIfNeeded()
                }
            }else{
                self.transform = .identity
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
    

    



