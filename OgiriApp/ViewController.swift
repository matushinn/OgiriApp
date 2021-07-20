//
//  ViewController.swift
//  OgiriApp
//
//  Created by 大江祥太郎 on 2021/07/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var odaiImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        commentTextView.layer.cornerRadius = 20.0
        
        //アルバムの許可を取る
        PHPhotoLibrary.requestAuthorization { (status) in
            switch(status){
            case .authorized:
                break
            case .notDetermined:
                break
            case .restricted:
                break
            case .denied:
                break
            case .limited:
                break
            @unknown default:
                break
            }
        }
        getImages(keyword: "funny")
    }
    
    //検索キーワードの値をもとに画像を引っ張ってくる
    //pixabay.com
    func getImages(keyword:String){
        //APIKey 22576227-26b7f5cefaed90131ae202127
        let url = "https://pixabay.com/api/?key=22576227-26b7f5cefaed90131ae202127&q=\(keyword)"
        
        //Alamofireを使って、httpリクエストを投げる
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{ (response) in
            switch response.result{
            
            case .success(_):
                //jsonでデータを取得する
                let json:JSON = JSON(response.data as Any)
                //詳しくはメモ帳(API応用)　配列の中の求めたいURLにアクセスする　countはボタンが押されたらカウントされる
                var imageString
                    = json["hits"][self.count]["webformatURL"].string
                
                //imageStringが無くなった時の処理
                if imageString == nil {
                    imageString
                        = json["hits"][0]["webformatURL"].string
                }
                /*
                 else{
                 self.odaiImageView.sd_setImage(with: URL(string:imageString!), completed: nil)
                 }
                 */
                self.odaiImageView.sd_setImage(with: URL(string:imageString!), completed: nil)
                
                
            case .failure(_):
                print("error")
            }
        }
        
        
    }
    
    @IBAction func nextOdai(_ sender: Any) {
        //次の画像を表示させるためにカウントを1増やす
        count += 1
        // getImages(keyword: <#T##String#>)
        
        if searchTextField.text == "" {
            getImages(keyword: "funny")
        }else{
            getImages(keyword: searchTextField.text!)
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        self.count = 0
        
        if searchTextField.text == "" {
            getImages(keyword: "funny")
        }else{
            getImages(keyword: searchTextField.text!)
        }

    }
    
    @IBAction func next(_ sender: Any) {
        performSegue(withIdentifier: "next", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let shareVC = segue.destination as? ShareViewController
        
        shareVC?.commentString = commentTextView.text
        shareVC?.resultImage = odaiImageView.image!
        
    }
    


}

