import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatViewController: MessagesViewController, MessagesDataSource, MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    let colors = Colors()
    private var userId = ""
    private var firestoreData: [FirestoreData]  = []
    private var messages: [Message] = []
    
    func currentSender() -> SenderType {
        return Sender(senderId: userId, displayName: "MyName")
    }
    
    func otherSender() -> SenderType {
        return Sender(senderId: "-1", displayName: "OtherName")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Firestore.firestore().collection("Messages").document().setData([
//            "date" :Date(),
//            "senderId": "testId",
//            "text": "text",
//            "userName": "testName"
//        ])
        
        Firestore.firestore().collection("Messages").getDocuments(completion: {
            (document, error) in
            if error != nil {
                print("ChatViewController error")
            } else {
                if let document = document {
                    for i in 0..<document.count {
                        var storeData = FirestoreData()
                        let targetDocument = document.documents[i]
                        storeData.date = (targetDocument.get("date")! as! Timestamp).dateValue()
                        storeData.senderId = targetDocument.get("senderId")! as? String
                        storeData.text = targetDocument.get("text")! as? String
                        storeData.userName = targetDocument.get("userName")! as? String
                        self.firestoreData.append(storeData)
                        print(self.firestoreData)
                    }
                }
                self.messages = self.getMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
        })
    
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate  = self
        messageInputBar.delegate = self
        messagesCollectionView.contentInset.top = 70
        messagesCollectionView.messagesDataSource = self
        
        // ヘッダー
        let uiView = UIView()
        uiView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        view.addSubview(uiView)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = colors.white
        label.text = "Doctor"
        label.frame = CGRect(x: 0, y: 20, width: 100, height: 40)
        label.center.x = view.center.x
        label.textAlignment = .center
        uiView.addSubview(label)
        
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(UIImage(named: "back"), for:.normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        uiView.addSubview(backButton)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size
            .width, height: 70)
        gradientLayer.colors = [colors.bluePurple.cgColor, colors.blue.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        uiView.layer.insertSublayer(gradientLayer, at: 0)
        //
        
        // 端末固有のuuid
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            userId = uuid
            print("💓userId is " + userId)
        }
    }
    
    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func getMessages() -> [Message] {
        var messageArray: [Message] = []
        for i in 0..<firestoreData.count {
            messageArray.append(createMessage(text: firestoreData[i].text!, date: firestoreData[i].date!, firestoreData[i].senderId!))
        }
        return messageArray
    }
    
    // MessageKitで使用するためのメッセージ作成
    func createMessage(text: String, date: Date, _ senderId: String) -> Message {
        let attributeText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        let sender = (senderId == userId) ? currentSender() : otherSender()
        return Message(attributedText: attributeText, sender: sender as! Sender, messageId: UUID().uuidString, date: date)
    }
    
    // MARK: MessagesDisplayDelegate
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? colors.blueGreen : colors.redOrange
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
}
