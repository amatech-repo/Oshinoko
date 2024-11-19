//
//  AuthModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/14.
//

import FirebaseAuth
import SwiftUI

class AuthModel: ObservableObject {
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let firebaseUser = result?.user {
                // FirebaseAuth.User をアプリの User 型にマッピング
                let user = User(
                    id: firebaseUser.uid,
                    name: firebaseUser.displayName ?? "No Name",
                    iconURL: ""
                )
                completion(.success(user))
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let firebaseUser = result?.user {
                // FirebaseAuth.User をアプリの User 型にマッピング
                let user = User(
                    id: firebaseUser.uid,
                    name: firebaseUser.displayName ?? "No Name",
                    iconURL: ""
                )
                completion(.success(user))
            }
        }
    }
}


