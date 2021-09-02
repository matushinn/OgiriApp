//
//  AuthCheck.swift
//  OgiriApp
//
//  Created by 大江祥太郎 on 2021/09/02.
//

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
