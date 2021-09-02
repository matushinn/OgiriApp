//
//  ViewController.swift
//  OgiriApp
//
//  Created by 大江祥太郎 on 2021/07/20.
//

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
