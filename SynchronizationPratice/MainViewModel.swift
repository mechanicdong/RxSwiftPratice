//
//  MainViewModel.swift
//  SynchronizationPratice
//
//  Created by 이동희 on 2022/04/17.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

struct MainViewModel {
    let disposeBag = DisposeBag()
    
    let idValid = BehaviorSubject<Bool>(value: false)
    let idInputText = BehaviorSubject<String>(value: "")
    
    let pwValid = BehaviorSubject<Bool>(value: false)
    let pwInputText = BehaviorSubject<String>(value: "")
    
    let jsonValid = BehaviorSubject<Bool>(value: false)
    let jsonSub = BehaviorSubject<String?>(value: "")
    

    //view에서 행해지는 로직을 viewModel로 옮기고 결과가 같은지 확인할것(4/17)
    func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }

    func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
    
    func downloadJson(URLs url: String) -> Observable<String?> {
        //1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, err in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    emitter.onNext(json)
                }
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
