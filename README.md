# OgiriApp
SwiftでPixabay Developer APIを使って大喜利アプリを作ってみたいと思います。
初心者にもわかりやすく、デザインパターン、コードの可読性もしっかり守っているので、APIの入門記事としてはぴったりかなと。
完成形はこちら！
![ezgif.com-gif-maker.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/7982cc19-e244-b2fc-6c55-a042869fb095.gif)

では始めていきます。ぜひ最後までご覧ください。

## UIの設計

このように配置していきます。

![スクリーンショット 2021-09-02 1.12.15.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/b9543bb9-ed42-bf93-b637-fce8cf9c4d76.png)

ViewController,ShareViewControllerを作り、IBOutlet接続します。

```swift:ViewController.swift
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var odaiImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextOdai(_ sender: Any) {
        
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        
    }
    
    @IBAction func next(_ sender: Any) {
        
    }
}
```

```swift:ShareViewController.swift
import UIKit

class ShareViewController: UIViewController {
    
    @IBOutlet weak var resultImageView: UIImageView!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func share(_ sender: Any) {
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        
    }
}
```

## 全体設計
UIができた後に、今回のアプリの設計を行なっていく。
![スクリーンショット 2021-09-02 10.22.00.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/26a69d24-316f-30be-5d56-f259d691bbfc.png)


![スクリーンショット 2021-09-02 10.28.38.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/09231a81-7066-48dc-0786-754aa0dff7d7.png)

## APIの取得
まず、APIの取得からやっていきたいと思います。
[Pixabay Developer API](https://pixabay.com/ja/service/about/api/)を使います。
操作は以下。

![スクリーンショット 2021-09-02 10.30.17.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/c7224858-0c73-d763-8688-add230f61805.png)

ログインをする、またアカウントがない場合は新規アカウント登録を行う。
それができたら、ここでAPIKeyを取得する。

![スクリーンショット 2021-09-02 10.31.14.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/3d46aac3-11be-c825-5ddf-86aa64d0b047.png)


そしてこのようにAPIを叩くと、JSONデータを変換してくれます。


![スクリーンショット 2021-09-02 10.34.39.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/5c59557b-1653-ee4c-7617-85f0e4986229.png)

これらのデータをうまく使い今回はアプリを作成していきます。

## OdaiManager
今回のAPIにおいてのロジックを管理するOdaiManagerを書いていきます。

```swift:OdaiManager.swift
import Foundation

struct OdaiManager {
    func getImages(with keyword:String,completion:@escaping ([Hits]?) -> ()){
        //APIKey 22576227-26b7f5cefaed90131ae202127
        let urlString = "https://pixabay.com/api/?key=22576227-26b7f5cefaed90131ae202127&q=\(keyword)"
        
        //①URL型に変換
        if let url = URL(string: urlString) {
            
            //②URLSessionを作る
            let session = URLSession(configuration: .default)
            //③SessionTaskを与える
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    
                    completion(nil)
                }
                
                if let safeData = data {
                    // print(response)
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(OdaiModel.self, from: safeData)
                        
                        completion(decodedData.hits)
                        
                        //print(decodedData.hits[0].webformaturl)
                        
                    } catch  {
                        print(String(describing: error))                        
                    }
                }
            }
            //④Taskを始める
            task.resume()
        }
    }
}
```

## OdaiModel
レスポンスしたデータをデコードするためのOdaiModelを作成していきます。

```swift:OdaiModel.swift
import Foundation

struct OdaiModel:Codable{
    let hits:[Hits]
}

struct Hits:Codable {
    let webformatURL:String
}
```

## ViewController
次に取得したデータをViewに反映させるためにViewControllerを作っていきます。
その前に画像のキャッシュのために便利な[SDWebImage](https://github.com/SDWebImage/SDWebImage)というライブラリを使いたいと思います。
SDWebImageの詳しい説明、導入の仕方などは[これら](https://qiita.com/hcrane/items/422811dfc18ae919f8a4)の記事を見るとわかると思います。

```swift:ViewController.swift
import UIKit
import SDWebImage
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var odaiImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var odaiManager = OdaiManager()
    
    var hits: [Hits] = []
    private var imageString = ""

    private var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        commentTextView.layer.cornerRadius = 20.0
        
        //アルバムの許可をとる
        AuthCheck().cameraCheck()
        
        odaiManager.getImages(with: "funny") { (hits) in
            guard let data = hits else{
                return
            }
            self.hits = data
            
            self.imageString = hits![self.count].webformatURL
            
            DispatchQueue.main.async {
                self.odaiImageView.sd_setImage(with: URL(string:self.imageString), completed: nil)
            }
            
        }
    }
    
    //検索キーワードの値をもとに画像を引っ張ってくる
    //pixabay.com
    @IBAction func nextOdai(_ sender: Any) {
        //次の画像を表示させるためにカウントを1増やす
        count += 1
        // getImages(keyword:)
        
        setUp()
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        self.count = 0
        
        setUp()
    }
    
    func setUp(){
        if searchTextField.text == "" {
            odaiManager.getImages(with: "funny") { (hits) in
                guard let data = hits else{
                    return
                }
                self.hits = data
                
                self.imageString = hits![self.count].webformatURL
                
                DispatchQueue.main.async {
                    self.odaiImageView.sd_setImage(with: URL(string:self.imageString), completed: nil)
                }
            }
        }else{
            if let text = searchTextField.text {
                odaiManager.getImages(with: text) { (hits) in
                    guard let data = hits else{
                        return
                    }
                    self.hits = data
                    
                    self.imageString = hits![self.count].webformatURL
                    
                    DispatchQueue.main.async {
                        self.odaiImageView.sd_setImage(with: URL(string:self.imageString), completed: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func next(_ sender: Any) {
        performSegue(withIdentifier: "toShare", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let shareVC = segue.destination as? ShareViewController
        
        if let comment = commentTextView.text,let image = odaiImageView.image {
            shareVC?.commentString = comment
            shareVC?.resultImage = image
        }
    }
}
```
ここでアルバムの許可画面を作るためのモデルを作っていきたいと思います。

```swift:AuthCheck.swift
import Foundation
import Photos

class AuthCheck {   
    func cameraCheck(){
        // ユーザーに許可を促す.
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            
            switch(status){
            case .authorized:
                print("Authorized")
                
            case .denied:
                print("Denied")
                
            case .notDetermined:
                print("NotDetermined")
                
            case .restricted:
                print("Restricted")
            case .limited:
                print("limited")
            @unknown default:
                return
            }
        }
    }
}
```
また、Info.plistの設定で
![スクリーンショット 2021-09-02 10.43.15.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/f7ef2569-5333-c54f-994b-78cebc2c64b6.png)
このような設定も各自行ってください。

## ShareViewController

```swift:ShareViewController.swift
import UIKit

class ShareViewController: UIViewController {
    
    var resultImage = UIImage()
    var commentString = String()
    
    var screenShotImage = UIImage()
    
    @IBOutlet weak var resultImageView: UIImageView!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultImageView.image = resultImage
        commentLabel.text = commentString
        commentLabel.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func share(_ sender: Any) {
        //スクリーンショットを撮る
        takeScreenShot()
        
        let items = [screenShotImage] as [Any]
        
        //アクティビティービューに乗っけて、シェアする
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(activityVC, animated: true, completion: nil)
    }
    
    func takeScreenShot(){
        let width = CGFloat(UIScreen.main.bounds.size.width)
        let height = CGFloat(UIScreen.main.bounds.size.height/1.3)
        
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        //viewに書き出す
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        screenShotImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
```

# 最後に
以上で完成した動画が以下です。
![ezgif.com-gif-maker.gif](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/325764/7982cc19-e244-b2fc-6c55-a042869fb095.gif)

コードは[こちら](https://github.com/matushinn/OgiriApp)に載せてあります。
指摘点がありましたら、コメントでもよろしくお願いします。



