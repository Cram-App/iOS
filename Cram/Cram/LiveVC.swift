//
//  LiveVC.swift
//  Cram
//
//  Created by Pablo Garces on 12/2/17.
//  Copyright © 2017 Cram. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import SDWebImage
import Firebase
import GameKit
import SwiftyJSON

var type = String()
var topic = String()
var gameRef : DatabaseReference!
//implement type and follow database event

class LiveVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var liveCollectionView: UICollectionView!
    @IBOutlet weak var pullTab: UIView!
    @IBOutlet weak var questionBack: UIView!
    @IBOutlet weak var btnBack1: UIView!
    @IBOutlet weak var btnText1: UILabel!
    @IBOutlet weak var btnBack2: UIView!
    @IBOutlet weak var btnText2: UILabel!
    @IBOutlet weak var btnBack3: UIView!
    @IBOutlet weak var btnText3: UILabel!
    @IBOutlet weak var btnBack4: UIView!
    @IBOutlet weak var btnText4: UILabel!
    @IBOutlet weak var leadImg: UIImageView!
    @IBOutlet weak var leadPoints: UILabel!
    @IBOutlet weak var leadBack: UIView!
    @IBOutlet weak var timerBack: UIView!
    @IBOutlet weak var leadText: UILabel!
    @IBOutlet weak var questionCountText: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var timer: KDCircularProgress!
    @IBOutlet weak var answerStatus: UIImageView!
    
    @IBOutlet weak var waitingRoomTableView: UITableView!
    @IBOutlet weak var waitingMessage: UILabel!
    @IBOutlet weak var waitingBtnBack: UIView!
    @IBOutlet weak var waitingRoomBackView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var gameID: UILabel!
    @IBOutlet weak var startGameBtnText: UILabel!
    @IBOutlet weak var cancelGameBtn: UIButton!
    
    var friendsInMatchID = [String]()
    var friendsInMatchName = [String]()
    var gameInitialized = false
    
    var gamePoints = 0
    var totalSecondsCountDown = 10.0
    var gameTimer: Timer!
    var gameLeadboard = [String: (String, Int, Int)]() //id, name, totalPoints, gamePoints
    var purple = UIColor(displayP3Red: 95/255, green: 49/255, blue: 146/255, alpha: 1.0)
    var green = UIColor(displayP3Red: 101/255, green: 195/255, blue: 163/255, alpha: 1.0)
    var lightThemeGrey = UIColor(displayP3Red: 184/255, green: 184/255, blue: 184/255, alpha: 1.0)
    var veryLightGrey = UIColor(displayP3Red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    
    var questions =
    [
        "This is a question that was generated automatically from a course video lecture! ONE",
        "This is a question that was generated automatically from a course video lecture! TWO",
        "This is a question that was generated automatically from a course video lecture! THREE",
        "This is a question that was generated automatically from a course video lecture! FOUR"
    ]
    var answerIndexArray = [Int]()
    var buttonOneArray = [String]()
    var buttonTwoArray = [String]()
    var buttonThreeArray = [String]()
    var buttonFourArray = [String]()
    var friendsInGame =
    [
        "You"
    ]
    
    var questionArray = [String]()
    
    var bt1 = [String]()
    var bt2 = [String]()
    var bt3 = [String]()
    var bt4 = [String]()
    
    var answers = [Int]()
    
    var friendsInGamePics = [
        UIImage()
    ]
    var friendsInGamePoints =
    [
        userPoints
    ]
    var mainBorderWidth: CGFloat = 2.0
    
    var btn1Selected = false
    var btn2Selected = false
    var btn3Selected = false
    var btn4Selected = false
    var activityIndicatorView = UIActivityIndicatorView()
    var loaderMessage = UILabel()
    
    var pointsEarned = 0
    // Question results
    @IBOutlet weak var questionWinner: UIView!
    @IBOutlet weak var questionWinnerImg: UIImageView!
    @IBOutlet weak var questionWinnerText: UILabel!
    @IBOutlet weak var yourPoints: UILabel!
    @IBOutlet weak var closeGameBtnBack: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("beggining to load Live page")
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(topPulled))
        edgePan.edges = .bottom
        view.addGestureRecognizer(edgePan)
        
        waitingRoomBackView.isHidden = false
        countdownLabel.isHidden = true
        
        liveCollectionView.dataSource = self
        liveCollectionView.delegate = self
        waitingRoomTableView.dataSource = self
        waitingRoomTableView.delegate = self
        
        pullTab.layer.cornerRadius = pullTab.frame.size.height / 2
        questionBack.layer.cornerRadius = 6
        
        leadBack.layer.cornerRadius = leadBack.frame.size.height / 2
        leadBack.layer.masksToBounds = true
        leadImg.layer.cornerRadius = leadImg.frame.size.height / 2
        leadImg.layer.masksToBounds = true
        timerBack.layer.cornerRadius = timerBack.frame.size.height / 2
        timerBack.layer.masksToBounds = true
        
        timer.angle = 360
        answerStatus.alpha = 0.0
        waitingBtnBack.layer.cornerRadius = waitingBtnBack.frame.size.height / 2
        waitingBtnBack.layer.masksToBounds = true
        
        let headerHeight: CGFloat =  CGFloat(Int(waitingRoomTableView.rowHeight) * waitingRoomTableView.numberOfRows(inSection: 0)) / 2
        waitingRoomTableView.contentInset = UIEdgeInsetsMake(headerHeight, 0, -headerHeight, 0)
        
        // Game result
        closeGameBtnBack.layer.cornerRadius = closeGameBtnBack.frame.size.height / 2
        closeGameBtnBack.layer.masksToBounds = true
        questionWinnerImg.layer.cornerRadius = questionWinnerImg.frame.size.height / 2
        questionWinnerImg.layer.masksToBounds = true
        questionWinner.layer.cornerRadius = 6
        questionWinner.layer.masksToBounds = true
        questionWinner.alpha = 0.0
//
//        // DEMO ADDING A PERSON
//        let when = DispatchTime.now() + 3
//        DispatchQueue.main.asyncAfter(deadline: when) {
//
//            // THIS CRASHES
//            self.addFriend(name: "Brian", pic: "testface", points: 34)
//        }

        // Do any additional setup after loading the view.
        
        // Initial button styles
        resetButtons()
        
        // Loader
        activityIndicatorView.frame = CGRect(x: (view.frame.size.width / 2) - 30, y: (view.frame.size.height / 2) - 80, width: 60, height: 60)
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.isHidden = true
        view.addSubview(activityIndicatorView)
        
        self.leadPoints.text = "\(userPoints)"
        let picUrl = URL(string: "https://graph.facebook.com/\(userID)/picture?type=large")
        self.leadImg.sd_setImage(with: picUrl)
        
        loaderMessage.frame = CGRect(x: 40, y: activityIndicatorView.frame.maxY + 15, width: view.frame.size.width - 80, height: 50)
        loaderMessage.numberOfLines = 0
        loaderMessage.textAlignment = .center
        loaderMessage.font = UIFont(name: "Montserrat-Medium", size: 20)
        loaderMessage.lineBreakMode = .byWordWrapping
        loaderMessage.textColor = UIColor.white
        loaderMessage.isHidden = true
        view.addSubview(loaderMessage)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.btnBack1.layer.cornerRadius = self.btnBack1.frame.size.height / 2
            self.btnBack2.layer.cornerRadius = self.btnBack1.frame.size.height / 2
            self.btnBack3.layer.cornerRadius = self.btnBack1.frame.size.height / 2
            self.btnBack4.layer.cornerRadius = self.btnBack1.frame.size.height / 2
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.followGame()
        
        if type == "HOST" {
            
            startGameBtnText.text = "Start game!"
            cancelGameBtn.isHidden = false
            
        } else {
            
            startGameBtnText.text = "Exit game"
            cancelGameBtn.isHidden = true
        }
 
    }
    
    func addFriend(name: String, pic: UIImage, points: Int) {
        
        waitingRoomTableView.beginUpdates()
        
        let indexPath = IndexPath(row: friendsInGame.count, section: 0)
        waitingRoomTableView.insertRows(at: [indexPath], with: .bottom)
        
        friendsInGame.append(name)
        friendsInGamePics.append(pic)
        friendsInGamePoints.append(points)
        
        waitingRoomTableView.endUpdates()
        
    }
    
    // Live Collection View
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "liveCell", for: indexPath) as! LiveCell
        
        if indexPath.row < friendsInMatchID.count{
            let friendUrl = URL(string: "https://graph.facebook.com/\(friendsInMatchID[indexPath.row])/picture?type=large")
            cell.cellImg.sd_setImage(with: friendUrl)
            cell.points.text = "LIVE"
            
            if friendsInMatchName[indexPath.row] != ""{
                cell.cellName.text = String(friendsInMatchName[indexPath.row].split(separator: " ").first!)
            }
        }
        else{
            cell.cellImg.image = UIImage(named: "topic3")
        }
        
        
        cell.cellBack.layer.masksToBounds = true
        cell.cellImg.layer.masksToBounds = true
        cell.cellBack.layer.cornerRadius = 6
        cell.cellImg.layer.cornerRadius = 6

        cell.pointsBack.layer.masksToBounds = true
        cell.pointsBack.layer.cornerRadius = cell.pointsBack.frame.size.height / 2
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.gameLeadboard.count
    }
    
    func inGame(index: Int) {
        
        if index == questions.count {
            saveProfile()
            
            for subview in questionBack.subviews {
                if subview != questionWinner {
                    subview.fadeOut()
                } else {
                    subview.fadeIn()
                }
            }
            
            return
        }
        else{
        
        if index < buttonOneArray.count{
        //Question Set up
        self.questionCountText.text = "\(index + 1)/\(questions.count)"
        self.questionText.text = questions[index]
        
        self.btnText1.text = buttonOneArray[index]
        self.btnText2.text = buttonTwoArray[index]
        self.btnText3.text = buttonThreeArray[index]
        self.btnText4.text = buttonFourArray[index]
        
        //Fade In
        self.questionText.fadeIn()
        self.questionCountText.fadeIn()
        
        self.btnText1.fadeIn()
        self.btnText2.fadeIn()
        self.btnText3.fadeIn()
        self.btnText4.fadeIn()
        
        startCountDownTimer()
        
        let when = DispatchTime.now() + 10
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            // Get right answer and animate the status
            let rightAnswer = self.showCorrectAnswer(index: index)
            
            if rightAnswer == 1 && self.btn1Selected || rightAnswer == 2 && self.btn2Selected
                || rightAnswer == 3 && self.btn3Selected || rightAnswer == 4 && self.btn4Selected {
                
                self.gamePoints += self.pointsEarned
                //gameRef.child("leadboard/\(userID)/gamePoints").setValue(self.gamePoints)
                userPoints += self.pointsEarned
                self.leadPoints.text = "\(self.gamePoints) pts"
                saveProfile()
                
                self.answerStatus.image = UIImage(named: "check")
            } else {
                self.pointsEarned = 0
                self.answerStatus.image = UIImage(named: "wrong")
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.answerStatus.alpha = 1.0
                let scaleX = CGFloat(1.0)
                let scaleY = CGFloat(1.0)
                self.answerStatus.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            }, completion: nil)
            
            // Time in between questions
            let whenIn = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: whenIn) {
                
                // Reset the answer status
                UIView.animate(withDuration: 0.5, animations: {
                    self.answerStatus.alpha = 0.0
                    let scaleX = CGFloat(0.5)
                    let scaleY = CGFloat(0.5)
                    self.answerStatus.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                }, completion: nil)
                
                self.timer.animate(fromAngle: self.timer.angle, toAngle: 0.0, duration: 1.0, completion: nil)
                self.totalSecondsCountDown = 10.0 + 1.0
                
                //Fadeout
                self.questionText.fadeOut()
                self.questionCountText.fadeOut()
                self.btnText1.fadeOut()
                self.btnText2.fadeOut()
                self.btnText3.fadeOut()
                self.btnText4.fadeOut()
                
                self.resetButtons()
                
                self.inGame(index: index + 1)
                
                }
            }
        }
        }
    }
    
    @objc func startLoading(){
        
        //Stops Loading and loads quiz
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.loaderMessage.isHidden = true
            
            self.countdownLabel.isHidden = false
            
            var bounds = self.countdownLabel.bounds
            self.countdownLabel.font = self.countdownLabel.font.withSize(200)
            bounds.size = self.countdownLabel.intrinsicContentSize
            self.countdownLabel.bounds = bounds
            let scaleX = CGFloat(0.25)
            let scaleY = CGFloat(0.25)
            self.countdownLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            UIView.animate(withDuration: 1.0) {
                self.countdownLabel.transform = .identity
                
            }
            
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                self.countdownLabel.text = "2"
                
                var bounds = self.countdownLabel.bounds
                self.countdownLabel.font = self.countdownLabel.font.withSize(200)
                bounds.size = self.countdownLabel.intrinsicContentSize
                self.countdownLabel.bounds = bounds
                let scaleX = CGFloat(0.25)
                let scaleY = CGFloat(0.25)
                self.countdownLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                
                UIView.animate(withDuration: 1.0) {
                    self.countdownLabel.transform = .identity
                    
                }
            }
            
            let whenTwo = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: whenTwo) {
                
                self.countdownLabel.text = "1"
                
                var bounds = self.countdownLabel.bounds
                self.countdownLabel.font = self.countdownLabel.font.withSize(200)
                bounds.size = self.countdownLabel.intrinsicContentSize
                self.countdownLabel.bounds = bounds
                let scaleX = CGFloat(0.25)
                let scaleY = CGFloat(0.25)
                self.countdownLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                
                UIView.animate(withDuration: 1.0) {
                    self.countdownLabel.transform = .identity
                    
                }
                
            }
            
            let whenThree = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: whenThree) {
                
                // Starts game
                self.waitingRoomBackView.isHidden = true
                self.inGame(index: 0)
            }

            
        }
        
    }
    
    @IBAction func startGameBtnClicked(_ sender: Any) {
        
        print("type", type)
        if type == "HOST"{
            
            questionArray = [String]()
            
            bt1 = [String]()
            bt2 = [String]()
            bt3 = [String]()
            bt4 = [String]()
            
            var answers = [Int]()
            
            self.generateQuestions(topic: topic)
        } else {
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
   
    
   
    @IBAction func closeGameBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelGameBtnClicked(_ sender: Any) {
        // Do Stuff
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func updateTimer() {
        
        if self.totalSecondsCountDown > 0 {
            self.totalSecondsCountDown = self.totalSecondsCountDown - 1
            print("Timer countdown: \(self.totalSecondsCountDown) + \(timer.angle)")
            
            //timer.angle = 360.0 * (10.0 / Double(totalSecondsCountDown))
            timer.animate(fromAngle: timer.angle, toAngle: 360.0 * (Double(totalSecondsCountDown) / 10.0), duration: 1, completion: nil)
            
        } else {
            self.stopCountDownTimer();
            print("Timer stops...")
            
        }
        
    }
    
    func startCountDownTimer() {
        
        if self.gameTimer != nil {
            self.gameTimer.invalidate()
            self.gameTimer = nil
        }
        
        if self.totalSecondsCountDown > 0 {
            self.gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(self.gameTimer, forMode: RunLoopMode.commonModes)
            self.gameTimer.fire()
        }
        
    }
    
    func stopCountDownTimer() {
        if self.gameTimer != nil {
            self.gameTimer.invalidate()
            self.gameTimer = nil
        }
        
    }
    
    @objc func topPulled(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        
        if recognizer.state == .recognized {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "joinedFriend", for: indexPath) as! JoinedFriend
        cell.backgroundColor = UIColor.white
        cell.friendName.text = "\(friendsInGame[indexPath.row].split(separator: " ").first!) joined!"
        
        if indexPath.row == 0{
            let picUrl = URL(string: "https://graph.facebook.com/\(userID)/picture?type=large")
            cell.friendImg.sd_setImage(with: picUrl)
        }
        else{
            cell.friendImg.image = friendsInGamePics[indexPath.row]
        }
        cell.friendPoints.text = "\(friendsInGamePoints[indexPath.row])"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friendsInGame.count
        
    }
    
    // Button actions
    @IBAction func buttonOnePressed(_ sender: Any) {
        
        if !btn1Selected && !btn2Selected && !btn3Selected && !btn4Selected {
            btnBack1.backgroundColor = purple
            btnText1.textColor = UIColor.white
            btnBack1.layer.borderWidth = mainBorderWidth
            btnBack1.layer.borderColor = purple.cgColor
        btn1Selected = true
            
            pointsEarned = Int(self.totalSecondsCountDown)
        }
    }
    
    @IBAction func buttonTwoPressed(_ sender: Any) {
        if !btn1Selected && !btn2Selected && !btn3Selected && !btn4Selected {
            btnBack2.backgroundColor = purple
            btnText2.textColor = UIColor.white
            btnBack2.layer.borderWidth = mainBorderWidth
            btnBack2.layer.borderColor = purple.cgColor
        btn2Selected = true
            
            pointsEarned = Int(self.totalSecondsCountDown)
        }
    }
    
    @IBAction func buttonThreePressed(_ sender: Any) {
        if !btn1Selected && !btn2Selected && !btn3Selected && !btn4Selected {
            btnBack3.backgroundColor = purple
            btnText3.textColor = UIColor.white
            btnBack3.layer.borderWidth = mainBorderWidth
            btnBack3.layer.borderColor = purple.cgColor
        btn3Selected = true
            
            pointsEarned = Int(self.totalSecondsCountDown)
        }
    }
    
    @IBAction func buttonFourPressed(_ sender: Any) {
        if !btn1Selected && !btn2Selected && !btn3Selected && !btn4Selected {
            btnBack4.backgroundColor = purple
            btnText4.textColor = UIColor.white
            btnBack4.layer.borderWidth = mainBorderWidth
            btnBack4.layer.borderColor = purple.cgColor
        btn4Selected = true
            
            pointsEarned = Int(self.totalSecondsCountDown)
        }
    }
    
    func resetButtons() {
        
        btn1Selected = false
        btn2Selected = false
        btn3Selected = false
        btn4Selected = false
        
        btnBack1.backgroundColor = UIColor.clear
        btnText1.textColor = purple
        btnBack1.layer.borderWidth = mainBorderWidth
        btnBack1.layer.borderColor = purple.cgColor
        btnBack2.backgroundColor = UIColor.clear
        btnText2.textColor = purple
        btnBack2.layer.borderWidth = mainBorderWidth
        btnBack2.layer.borderColor = purple.cgColor
        btnBack3.backgroundColor = UIColor.clear
        btnText3.textColor = purple
        btnBack3.layer.borderWidth = mainBorderWidth
        btnBack3.layer.borderColor = purple.cgColor
        btnBack4.backgroundColor = UIColor.clear
        btnText4.textColor = purple
        btnBack4.layer.borderWidth = mainBorderWidth
        btnBack4.layer.borderColor = purple.cgColor
    }
    
    func showCorrectAnswer(index: Int) -> Int {
        
        // Compares Selected Cell with right answer
        let correctAnswer = answerIndexArray[index] + 1
        
        if correctAnswer == 1 {
            
            btnBack1.backgroundColor = green
            btnText1.textColor = UIColor.white
            btnBack1.layer.borderWidth = mainBorderWidth
            btnBack1.layer.borderColor = green.cgColor
            // ---
            btnBack2.backgroundColor = veryLightGrey
            btnText2.textColor = purple
            btnBack2.layer.borderWidth = mainBorderWidth
            btnBack2.layer.borderColor = purple.cgColor
            btnBack3.backgroundColor = veryLightGrey
            btnText3.textColor = purple
            btnBack3.layer.borderWidth = mainBorderWidth
            btnBack3.layer.borderColor = purple.cgColor
            btnBack4.backgroundColor = veryLightGrey
            btnText4.textColor = purple
            btnBack4.layer.borderWidth = mainBorderWidth
            btnBack4.layer.borderColor = purple.cgColor
    
            return 1

            
        } else if correctAnswer == 2 {
            
            btnBack2.backgroundColor = green
            btnText2.textColor = UIColor.white
            btnBack2.layer.borderWidth = mainBorderWidth
            btnBack2.layer.borderColor = green.cgColor
            // ---
            btnBack1.backgroundColor = veryLightGrey
            btnText1.textColor = purple
            btnBack1.layer.borderWidth = mainBorderWidth
            btnBack1.layer.borderColor = purple.cgColor
            btnBack3.backgroundColor = veryLightGrey
            btnText3.textColor = purple
            btnBack3.layer.borderWidth = mainBorderWidth
            btnBack3.layer.borderColor = purple.cgColor
            btnBack4.backgroundColor = veryLightGrey
            btnText4.textColor = purple
            btnBack4.layer.borderWidth = mainBorderWidth
            btnBack4.layer.borderColor = purple.cgColor
    
            return 2
            
        } else if correctAnswer == 3 {
            
            btnBack3.backgroundColor = green
            btnText3.textColor = UIColor.white
            btnBack3.layer.borderWidth = mainBorderWidth
            btnBack3.layer.borderColor = green.cgColor
            // ---
            btnBack2.backgroundColor = veryLightGrey
            btnText2.textColor = purple
            btnBack2.layer.borderWidth = mainBorderWidth
            btnBack2.layer.borderColor = purple.cgColor
            btnBack1.backgroundColor = veryLightGrey
            btnText1.textColor = purple
            btnBack1.layer.borderWidth = mainBorderWidth
            btnBack1.layer.borderColor = purple.cgColor
            btnBack4.backgroundColor = veryLightGrey
            btnText4.textColor = purple
            btnBack4.layer.borderWidth = mainBorderWidth
            btnBack4.layer.borderColor = purple.cgColor
    
            return 3
            
        } else {
            
            btnBack4.backgroundColor = green
            btnText4.textColor = UIColor.white
            btnBack4.layer.borderWidth = mainBorderWidth
            btnBack4.layer.borderColor = green.cgColor
            // ---
            btnBack2.backgroundColor = veryLightGrey
            btnText2.textColor = purple
            btnBack2.layer.borderWidth = mainBorderWidth
            btnBack2.layer.borderColor = purple.cgColor
            btnBack3.backgroundColor = veryLightGrey
            btnText3.textColor = purple
            btnBack3.layer.borderWidth = mainBorderWidth
            btnBack3.layer.borderColor = purple.cgColor
            btnBack1.backgroundColor = veryLightGrey
            btnText1.textColor = purple
            btnBack1.layer.borderWidth = mainBorderWidth
            btnBack1.layer.borderColor = purple.cgColor
    
            return 4
            }
            
        
    }
    
    func generateQuestions(topic: String) -> Void {
        //        let url = "https://cram.heroku.com/questions?topic=\(topic)"
        
        print("topic", topic)
        let joinedTopic = topic.replacingOccurrences(of: " ", with: "%20")
        print("joinedTopic", joinedTopic)
        if let queryURL =  URL(string: "https://cram.herokuapp.com/questions?topic=\(joinedTopic)"){
        
        let session = URLSession.shared
        session.dataTask(with: queryURL) { (data, response, error) in
            if let response = response {
                print("response", response)
            }
            if let data = data {
                print("data", data)
                //do {
                let json = JSON(data)
                let qCount = json.count
                var i = 0
                print(qCount)
                print(json[0])
                self.questions = []
                while i < qCount {
                    if (json[i]["similar_words"].count >= 3) {
                        //                        print(json[i])
                        let question = json[i]["question"]
                        
                        let answer = json[i]["answer"]
                        
                        let diceRoll = Int(arc4random_uniform(UInt32(4)))
                        
                        if diceRoll == 0{
                            self.bt1.append(answer.string!)
                            self.bt2.append(json[i]["similar_words"][0].string!)
                            self.bt3.append(json[i]["similar_words"][1].string!)
                            self.bt4.append(json[i]["similar_words"][2].string!)
                        }
                        else if diceRoll == 1{
                            self.bt1.append(json[i]["similar_words"][0].string!)
                            self.bt2.append(answer.string!)
                            self.bt3.append(json[i]["similar_words"][1].string!)
                            self.bt4.append(json[i]["similar_words"][2].string!)
                        }
                        else if diceRoll == 2{
                            self.bt1.append(json[i]["similar_words"][1].string!)
                            self.bt2.append(json[i]["similar_words"][0].string!)
                            self.bt3.append(answer.string!)
                            self.bt4.append(json[i]["similar_words"][2].string!)
                        }
                        else if diceRoll == 3{
                            self.bt1.append(json[i]["similar_words"][2].string!)
                            self.bt2.append(json[i]["similar_words"][0].string!)
                            self.bt3.append(json[i]["similar_words"][1].string!)
                            self.bt4.append(answer.string!)
                        }
                        
                        self.questionArray.append(question.string!)
                        
                        self.answers.append(diceRoll)
                        
                        
                        print("question", question)
                        print("answer", answer)
                        //self.questions.append(question)
                    

                        
                        print(question)
                        
                        
                        
                        //                        self.questions.append(self.jsonToString(json: q as AnyObject))
                    }
                    i += 1
                }
                
                let questionsDB: [String: Any] = ["titles" : self.questionArray, "bt1" : self.bt1, "bt2" : self.bt2, "bt3" : self.bt3, "bt4" : self.bt4, "answers" : self.answers]
                
                gameRef.child("questions").setValue(questionsDB)
                
                //creates dalay for NSDate
                var date = Date()
                date.addTimeInterval(5)
                
                gameRef.child("startingDate").setValue(date.timeIntervalSince1970)
                
            }
            }.resume()
        }
        else{
            print("string to url error")
        }
        
        
    }
    
    func followGame(){
        
        if gameRef != nil{
            gameRef.observe(.value, with: {(snapshot) in

                if( snapshot.value is NSNull){
                    print("Invalid or expired game")
                    return
                }
                else{
                    print("Game Changed")
                    var data  = snapshot.value! as! [String: Any]
                    
                    if let timeSince1970 = data["startingDate"] as? Double {
                        
                        //creates dalay for NSDate
                        let date = Date(timeIntervalSince1970: timeSince1970)
                        
                        Timer.scheduledTimer(timeInterval: TimeInterval(date.timeIntervalSinceNow), target: self, selector: #selector(self.startLoading), userInfo: nil, repeats: false)
                        
                        
                        // Starts Loader
                        for subview in self.waitingRoomBackView.subviews {
                            subview.isHidden = true
                        }
                        
                        self.activityIndicatorView.startAnimating()
                        self.activityIndicatorView.isHidden = false
                        self.loaderMessage.text = "Converting your lecture into a fun quiz, hang tight!"
                        self.loaderMessage.isHidden = false
                        
                        
                    }
                    
                    if let questionData = data["questions"] as? [String: Any]{
                        if self.gameInitialized == false{
                            print("questions")
                            print(questionData["titles"] as! [String])
                            self.questions = questionData["titles"] as! [String]
                            self.buttonOneArray = questionData["bt1"] as! [String]
                            self.buttonTwoArray = questionData["bt2"] as! [String]
                            self.buttonThreeArray = questionData["bt3"] as! [String]
                            self.buttonFourArray = questionData["bt4"] as! [String]
                            self.answerIndexArray = questionData["answers"] as! [Int]
                            
                            self.gameInitialized = true
                        }
                        
                    }
                    
                    
                    if let leadboard = data["leadboard"] as? [String : Any]{
                        print("Game Leadboard", leadboard)
                        self.gameLeadboard = [String: (String, Int, Int)]()

                        if (leadboard.count - 1) != self.gameLeadboard.count{
                            //for x in (leadboard.count - self.gameLeadboard.count)..<leadboard.count{ }
                            //Possible way to properly create animations
                            self.gameLeadboard = [String: (String, Int, Int)]()
                            
                            self.friendsInMatchID = [String]()
                            self.friendsInMatchName = [String]()
                            
                            for friend in leadboard{
                                if friend.key != userID{
                        
                                    let friendData = friend.value as! [String: Any]
                                    
                                    if let friendName = friendData["name"] as? String,
                                    let friendGP = friendData["gamePoints"] as? Int,
                                    let friendTP = friendData["totalPoints"] as? Int{
                                    
                                        //// id: (name, totalPoints, gamePoints)
                                        self.gameLeadboard[friend.key] = (friendName, friendGP, friendTP)
                                        
                                        self.friendsInMatchID.append(friend.key)
                                        self.friendsInMatchName.append(friendName)
                                    }
                                    else{
                                        print("incorrect friend style")
                                    }
                                    
    
                                }
                            }
                            self.liveCollectionView.reloadData()
                        }
                    }
                    for friend in self.gameLeadboard{
                        
                        let when = DispatchTime.now() + 3
                        let picUrl = URL(string: "https://graph.facebook.com/\(friend.key)/picture?type=large")
                        let friendPic = UIImageView()
                        friendPic.sd_setImage(with: picUrl)
                        let friendName = friend.value.0
                        let friendTP = friend.value.1
                        DispatchQueue.main.asyncAfter(deadline: when) {
                        self.addFriend(name: friendName, pic: friendPic.image!, points: friendTP)
                        }

                    }
                    

                }
                
            })
            
        }
//        if type != "" && gameRef != nil{
//            
//            gameRef.observe(.value, with: {(snapshot) in
//                
//                if( snapshot.value is NSNull){
//                    print("Invalid of expired game")
//                    return
//                }
//                else{
//                    var data  = snapshot.value! as! [String: Any]
//                    
//                    if let leadboard = data["leadboard"] as? [String : Any]{
//                        print("Game Leadboard", leadboard)
//                        
//                        if leadboard.count != self.gameLeadboard.count{
//                            //for x in (leadboard.count - self.gameLeadboard.count)..<leadboard.count{ }
//                            //Possible way to properly create animations
//                            self.gameLeadboard = [String: (String, Int, Int)]()
//                            for friend in leadboard{
//                                self.gameLeadboard["\(friend.key)"]
//                            }
//                        }
//                        
//                    }
//                    
//                }
//                
//                
//                
//            })
//        }
    }

}
