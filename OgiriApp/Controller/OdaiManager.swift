//
//  OdaiManager.swift
//  OgiriApp
//
//  Created by 大江祥太郎 on 2021/09/01.
//

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
