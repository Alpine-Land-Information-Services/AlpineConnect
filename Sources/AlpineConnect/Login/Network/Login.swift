//
//  File.swift
//  
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation


class Login {
    
    static let shared = Login()
    
//    func PasswordSaltedSHA(for password:String) -> String {
//        let salt = password + "#com.alpinelis.rmsdataapp#"
//        let sha1 = salt.sha1()
//        return sha1
//    }
//
//    func assignUser(in managedObjectContext: NSManagedObjectContext, user: User) {
//        managedObjectContext.perform {
//            DB.shared.currentUser = user
//            DB.shared.currentUserGUID = user.guid
//        }
//    }
    
    func loginUser(_ userName: String, _ password: String, completionHandler: @escaping(LoginResponseMessage) -> ()) {
//        let modifiedPassword = PasswordSaltedSHA(for: password)
        
        NetworkManager.shared.pool?.withConnection { connectionRequestResponse in
            switch connectionRequestResponse {
            case .failure(let error):
                completionHandler(.networkError)
                assertionFailure("ASSERT ERROR: error \(error) encountered while checking for network connection during user login")
            case .success(let connection):
                completionHandler(.successfulLogin)
                print(connection)
//                do {
//                    DispatchQueue.main.async {
//                        UserAuthenticationManager.shared.user = user
//                        completionHandler(.successfulLogin)
//                        return;
//                    }
//
//                } catch {
//                    completionHandler(.networkError)
//                    assertionFailure("ASSERT ERROR: error \(error.localizedDescription) encountered while decoding user credentials during user login")
//                }
            }
        }
    }
}


