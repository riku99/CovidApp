import UIKit

struct Colors {
    let bluePurple = UIColor(red: 87/255, green: 99/255, blue: 175/255, alpha: 1)
    let blue = UIColor(red: 92/255, green: 137/255, blue: 200/255, alpha: 1)
    let white = UIColor.systemGray6
    let black = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
    let blueGreen = UIColor(red: 86/255, green: 196/255, blue: 197/255, alpha: 1)
    let redOrange = UIColor(red: 245/255, green: 141/255, blue: 116/255, alpha: 1)
}

class ViewController: UIViewController {
    
    let colors = Colors()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGradation()
        setUpContent()
    }
    
    func setUpContent() {
        let contentView = UIView()
        contentView.frame.size = CGSize(width: view.frame.size.width, height: 340)
        contentView.center = CGPoint(x: view.center.x, y: view.center.y) // この要素の真ん中をviewの真ん中に合わせる
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowColor = UIColor.gray.cgColor
        contentView.layer.shadowOpacity = 0.5
        view.addSubview(contentView)
        
        view.backgroundColor = .systemGray6
        
        let labelFont = UIFont.systemFont(ofSize: 15, weight: .heavy)
        let size = CGSize(width: 150, height: 50)
        let color = colors.bluePurple
        let leftX = view.frame.size.width * 0.33
        let rightX = view.frame.size
            .width * 0.80
        setUpLabel("Covid in Japan", size: CGSize(width: 180, height: 35), centerX: view.center.x - 20, y: -60, font: .systemFont(ofSize: 25, weight: .heavy), color: .white, contentView) // yの位置はcontentViewから-60
        setUpLabel("PCR数", size: size, centerX: leftX, y: 20, font: labelFont, color: color, contentView)
        setUpLabel("感染者数", size: size, centerX: rightX, y: 20, font: labelFont, color: color, contentView)
        setUpLabel("入院者数", size: size, centerX: leftX, y: 120, font: labelFont, color: color, contentView)
        setUpLabel("重症者数", size: size, centerX: rightX, y: 120, font: labelFont, color: color, contentView)
        setUpLabel("死者数", size: size, centerX: leftX, y: 220, font: labelFont, color: color, contentView)
        setUpLabel("退院者数", size: size, centerX: rightX, y: 220, font: labelFont, color: color, contentView)
        
        let height = view.frame.size
            .height / 2
        setUpButton("健康管理", size: size, y: height + 190, color: colors.blue, parentView: view).addTarget(self, action: #selector(goHealthCheck), for: .touchDown)
        setUpButton("県別状況", size: size, y: height + 240, color: colors.blue, parentView: view).addTarget(self, action: #selector(goChart), for: .touchDown)
        
        // UIButtonのaddTargetでアクション時の関数を指定
        // selfはこの viewController 自体
        // UIKitの仕組み的にactionにはobjcのメソッドを指定する必要がある。Swiftでは #selector によってobjcのメソッドを指定できる。
        setUpImageButton("chat", x: view.frame.size
            .width - 50).addTarget(self, action: #selector(chatAction), for: .touchDown)
        setUpImageButton("relaod", x: 10).addTarget(self, action: #selector(reloadAction), for: .touchDown)
        
        let imageView = UIImageView()
        let image = UIImage(named: "virus")
        imageView.image = image
        // xをview.frame.size.widthとすることで画面外に配置
        imageView.frame = CGRect(x: view.frame.size.width, y: -65, width: 50, height: 50)
        contentView.addSubview(imageView)
        
        // アニメーションの実現
        UIView.animate(withDuration: 1.5, delay: 0.5, options: [.curveEaseIn], animations: {
            imageView.frame = CGRect(x: self.view.frame.size.width - 100, y: -65, width: 50, height: 50)
            imageView.transform = CGAffineTransform(rotationAngle: -90) // 90度回転
        }, completion: nil)
        
        setUpAPI(parentView: contentView)
    }
    
    func setUpAPI(parentView: UIView) {
        let pcr = UILabel()
        let positive = UILabel()
        let hospitalize = UILabel()
        let severe = UILabel()
        let death = UILabel()
        let discharge = UILabel()
        
        let size = CGSize(width: 200, height: 40)
        let leftX = view.frame.size.width * 0.38
        let rightX = view.frame.size.width * 0.85
        let font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        let color = colors.blue
        
        setUpApiLabel(pcr, size: size, centerX: leftX, y: 60, font: font, color: color, parentView)
        setUpApiLabel(positive, size: size, centerX: rightX, y: 60, font: font, color: color, parentView)
        setUpApiLabel(hospitalize, size: size, centerX: leftX, y: 160, font: font, color: color, parentView)
        setUpApiLabel(severe, size: size, centerX: rightX, y: 160, font: font, color: color, parentView)
        setUpApiLabel(death, size: size, centerX: leftX, y: 260, font: font, color: color, parentView)
        setUpApiLabel(discharge, size: size, centerX: rightX, y: 260, font: font, color: color, parentView)
        
        CovidAPI.getTotal(completion: {(result: CovidInfo.Total) -> Void in
            // クロージャの中は基本メインスレッドで行われない
            // DispatchQueue.main.asyncに処理を渡すことでメインスレッドで行われる。ここは表示に関する処理なのでメインスレッドで行う
            DispatchQueue.main.async {
                pcr.text = "\(result.pcr)"
                positive.text = "\(result.positive)"
                hospitalize.text = "\(result.hospitalize)"
                severe.text = "\(result.severe)"
                death.text = "\(result.death)"
                discharge.text = "\(result.discharge)"
            }
        })
    }
    
    func setUpApiLabel(_ label: UILabel, size: CGSize, centerX: CGFloat, y: CGFloat, font: UIFont, color: UIColor, _ parentView: UIView) {
        label.frame.size = size
        label.center.x = centerX
        label.frame.origin.y = y
        label.font = font
        label.textColor = color
        parentView.addSubview(label)
    }
    
    func setUpImageButton(_ name: String, x: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: name), for: .normal)
        button.frame.size = CGSize(width: 30, height: 30)
        button.tintColor = .white // 設定した画像の色変更
        button.frame.origin = CGPoint(x: x, y: 25)
        view.addSubview(button)
        return button
    }
    
    // objcのメソッドであると認識させるために @objc を付与
    @objc func chatAction() {
        performSegue(withIdentifier: "goChat", sender: nil)
    }
    
    @objc func reloadAction() {
        // loadView, viewDidLoad 共に UIViewController のライフサイクルメソッド
        // デフォルトのライフサイクルも loadView -> viewDidLoad の流れ
        loadView()
        viewDidLoad()
    }
    
    @objc func goHealthCheck() {
        // Main.で設定したセグエの名前のスクリーンに遷移
        performSegue(withIdentifier: "goHealthCheck", sender: nil)
    }
    
    @objc func goChart() {
        performSegue(withIdentifier: "goChart", sender: nil)
    }
    
    func setUpButton(_ title: String, size: CGSize, y: CGFloat, color: UIColor, parentView: UIView) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.frame.size = size
        button.center.x = view.center.x
        // 文字の間隔など特定のレイアウトを実装するときにNSAttributedStringを使用する。
        // ここでは NSAttributedString.Key.kern: 間隔 で文字列の間隔を指定
        let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.kern: 8.0])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.frame.origin.y = y
        button.setTitleColor(color, for: .normal)
        parentView.addSubview(button)
        return button
    }
    
    func setUpLabel(_ text: String, size: CGSize, centerX: CGFloat, y: CGFloat, font: UIFont, color: UIColor, _ parentView: UIView) {
        let label = UILabel()
        label.text = text
        label.frame.size = size
        label.center.x = centerX
        label.frame.origin.y = y
        label.font = font
        label.textColor = color
        parentView.addSubview(label)
    }
    
    func setUpGradation() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size
            .width, height: view.frame.size
            .height / 2)
        gradientLayer.colors = [colors.bluePurple.cgColor, colors.blue.cgColor] // cgColorでUIColorをCGColorに変換
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

