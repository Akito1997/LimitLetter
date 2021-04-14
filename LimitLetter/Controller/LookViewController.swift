//
//  LookViewController.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/24.
//


class animationLabel:UIView, CAAnimationDelegate{

    //プロパティ
    var title:String = ""
    var charMargin:CGFloat = 1
    var font:UIFont = UIFont(name: "Zapfino", size: 20)!
    var textColor : UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    var roopCount : Int = 0
    var shuffledLabel : [UILabel]!
    var animateDuration : Double = 5
    var labelRect : CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    let storybord=UIStoryboard(name: "Home", bundle: nil)

    private var labelArray : [UILabel] = []

    //イニシャライザ
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //文字列をランダムにフェードインさせる関数
    func shuffleFadeAppear(){
        self.animate(animationID: 1,random: false)
       
    }


    private func animate(animationID:Int , random:Bool = false){

        if(animationID == 1){

            var startx : CGFloat = labelRect.origin.x
            var count=0

            for chr in self.title{
                let label = UILabel()
                label.text = String(chr)
                label.textColor = self.textColor
                label.font = self.font
                label.sizeToFit()
                if startx>=self.frame.maxX{
                    startx=0
                    count+=30
                }
                label.frame.origin.x = startx
                startx += label.frame.width + self.charMargin
                label.frame.origin.y = labelRect.origin.y+CGFloat(count)
                label.alpha = 0
                self.addSubview(label)
                self.labelArray.append(label)
            }

            roopCount = 0
            if(random){
                self.labelArray.shuffle()
            }
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = animateDuration
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = false

            //透明度(opacity)を1から0にする
            let animation1 = CABasicAnimation(keyPath: "opacity")
            animation1.fromValue = 0.0
            animation1.toValue = 1.0

            animationGroup.animations = [animation1]
            animationGroup.delegate = self
            self.labelArray[0].layer.add(animationGroup, forKey: nil)
        }
        
    }


    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // アニメーションの終了
        if(roopCount == self.labelArray.count - 1){
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = animateDuration
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = false

            //透明度(opacity)を1から0にする
            let animation1 = CABasicAnimation(keyPath: "opacity")
            animation1.fromValue = 1.0
            animation1.toValue = 0.0

            animationGroup.animations = [animation1]
            animationGroup.delegate = self
//            animationGroup.beginTime = CACurrentMediaTime() + 0.1
            animationGroup.beginTime = CACurrentMediaTime() + 1

            self.layer.add(animationGroup, forKey: nil)
            roopCount += 1
        }
    }

    func animationDidStart(_ anim: CAAnimation){
        // アニメーションの開始
        if(roopCount < self.labelArray.count - 1){
            roopCount += 1

            let animationGroup = CAAnimationGroup()
            animationGroup.duration = animateDuration
            animationGroup.fillMode = CAMediaTimingFillMode.forwards
            animationGroup.isRemovedOnCompletion = false

            //透明度(opacity)を0から1にする
            let animation1 = CABasicAnimation(keyPath: "opacity")
            animation1.fromValue = 0.0
            animation1.toValue = 1.0

            animationGroup.animations = [animation1]
            animationGroup.delegate = self
//            animationGroup.beginTime = CACurrentMediaTime() + 0.5
            animationGroup.beginTime = CACurrentMediaTime() + 0.5
            self.labelArray[roopCount].layer.add(animationGroup, forKey: nil)
        }
    }

}
import UIKit
import Firebase
import Dispatch


class LookViewController:UIViewController{
    
    var userInfo:[LookRoom?]=[]
    var timer=Timer()
    let colors=[#colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1),#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)]
    var messages:[String]=[]
    var label=UILabel()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setbackground()

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(
            self,
            selector: #selector(self.setmessage),
            name:UIApplication.didBecomeActiveNotification,
            object: nil)
       
        
        
    
        label.textAlignment = .center
        label.font = label.font.withSize(20)
        label.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints=false
        view.addSubview(label)

    
        [label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
         label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor,constant: -45),
         label.widthAnchor.constraint(equalToConstant: self.view.bounds.width),
         label.heightAnchor.constraint(equalToConstant: 100)
        ].forEach {$0.isActive=true}
    }
    @objc private func setmessage(){
        let dt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "H", options: 0, locale: Locale(identifier: "ja_JP"))
        guard let t=Int(dateFormatter.string(from: dt).dropLast()) else {return}
        if (t>=19 && t<21){
            label.text=""
            messages=[]
            setInfo()
        }else{
            label.text="You can see messages between 19-21pm"
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setmessage()
    }
    private func setbackground(){
        let backImage = UIImageView(image: UIImage(named: "back"))
        backImage.frame=CGRect(x: 0, y: 0, width: self.view.frame.width,height: self.view.frame.height)
        backImage.contentMode = .scaleAspectFill
        self.view.addSubview(backImage)
    }
    private func setInfo(){
        Firestore.firestore().collection("messages")
            .getDocuments{(snapshot,err) in
                if let err=err{
                    print("情報の所得に失敗しました\(err)")
                }
                snapshot?.documents.forEach({ (user) in
                    let dic=user.data()
                    let userinfomation=LookRoom(dic: dic)
                    self.userInfo.append(userinfomation)
                })
                self.showUserInfo()
            }
        
    }
    private func showUserInfo(){
       
        for user in userInfo{
            guard let message=user?.message else {return}
            messages.append(message)
        }
        messages.shuffle()
        showlabel()
    }
    private func showlabel(){
        messages.insert("", at: 0)
        self.createtimer(index: 0)
    }
    
    private func createtimer(index:Int){
        timer=Timer.scheduledTimer(withTimeInterval: TimeInterval(messages[index].count), repeats: false) { (_) in
            
            let label = animationLabel(frame: self.view.frame)
            print(index)
            label.title = self.messages[index+1]
            label.textColor=self.colors.randomElement()!
            let randomInty = Int.random(in: 100..<500)
            let randomIntx=Int.random(in: 10..<80)
            let random=Int.random(in: 20..<50)
            let random_2=CGFloat.random(in: 15..<30)
            
            label.frame=CGRect(x:randomIntx, y:randomInty, width: Int(self.view.frame.maxX)-(110+random), height: 200);
            label.font=UIFont.systemFont(ofSize: random_2)
            self.view.addSubview(label)
            label.shuffleFadeAppear()
            self.timer.invalidate()
            if (index != (self.messages.count-2)){
                self.createtimer(index: index+1)
            }
        }
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
}

