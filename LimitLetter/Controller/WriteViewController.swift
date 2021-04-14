//
//  WriteVIewController.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/02/01.
//

import UIKit
import Firebase


class WriteViewController:UIViewController, UITextViewDelegate{
    var user:User?
    var LookRoom:LookRoom?
    var moziCount=0
    var userText=""
  
    @IBOutlet weak var LeaveMozi: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.backgroundColor=#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        textField.layer.cornerRadius=10
        textField.delegate=self
        postButton.isEnabled=false
        
        slider.setThumbImage(UIImage(), for: .normal)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LeaveMozi.text="残り"+String(moziCount)+"文字"

    }


    func textViewDidChange(_ textView: UITextView) {
        let Num=textField.text.count
        slider.value=Float(Num)
        if Num==0{
            postButton.isEnabled=false
            LeaveMozi.text="残り"+String(moziCount-Num)+"文字"
            LeaveMozi.textColor=#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        else if moziCount-Num<0 || Num>200{
            postButton.isEnabled=false
            LeaveMozi.textColor=#colorLiteral(red: 1, green: 0, blue: 0.2093637288, alpha: 1)
            LeaveMozi.text="残り"+String(moziCount-Num)+"文字"
        }
        else{
            postButton.isEnabled=true
            LeaveMozi.textColor=#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            LeaveMozi.text="残り"+String(moziCount-Num)+"文字"
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        userText=textField.text ?? ""
        return true
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
   
    @IBAction func send(_ sender: Any) {
        
        guard let text=textField.text else {return}
        guard let uid=Auth.auth().currentUser?.uid else {return}
        let name=UserDefaults.standard.string(forKey: "userName")!
        
        let docData=[
            "name":name,
            "message":text,
            "createdAt":Timestamp()
        ] as [String : Any]
        
        Firestore.firestore().collection("messages").document(uid).setData(docData){(err) in
            if let err=err{
                print("テキストの保存の失敗しました\(err)")
            }
            let Num=self.textField.text.count
            UserDefaults.standard.set(self.moziCount-Num, forKey: "moziNum")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func tappedBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension WriteViewController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}
