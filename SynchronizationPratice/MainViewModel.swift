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
    let jsonSub = BehaviorSubject<String>(value: "")

    //view에서 행해지는 로직을 viewModel로 옮기고 결과가 같은지 확인할것(4/17)
    func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }

    func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
    

}
