//
//  MainViewController.swift
//  SynchronizationPratice
//
//  Created by 이동희 on 2022/04/17.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MainViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let viewModel = MainViewModel()
    let idField = UITextField()
    let pwField = UITextField()
    let loginButton = UIButton()
    let idValidView = UIView()
    let pwValidView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(viewModel)
        attribute()
        layout()
    }
    
    func bind(_ viewModel: MainViewModel) {
        
        let idinputOb: Observable<String> = idField.rx.text.orEmpty.asObservable()
        let idValidOb: Observable<Bool> = idinputOb.map(checkEmailValid(_:))
        
        let pwInputOb: Observable<String> = pwField.rx.text.orEmpty.asObservable()
        let pwValidOb: Observable<Bool> = pwInputOb.map(checkPasswordValid(_:))
        
        idValidOb
            .subscribe(onNext: { b in
                self.idValidView.isHidden = b
            })
            .disposed(by: disposeBag)
        
        pwValidOb
            .subscribe(onNext: { b in
                self.pwValidView.isHidden = b
            })
            .disposed(by: disposeBag)
        
        idField.rx.text.orEmpty
            .map(checkEmailValid)
            .subscribe(onNext: { b in
                self.idValidView.isHidden = b
            })
            .disposed(by: disposeBag)
        
        pwField.rx.text.orEmpty
            .map(checkPasswordValid)
            .subscribe(onNext: { b in
                self.pwValidView.isHidden = b
                self.loginButton.isEnabled = b
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                idValidOb,
                pwValidOb,
                resultSelector: { $0 && $1 }
            )
            .subscribe(onNext: { b in
                self.loginButton.isEnabled = b
            })
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        view.backgroundColor = .white
        
        idField.backgroundColor = .systemGray
        pwField.backgroundColor = .systemGray
        idField.font = .systemFont(ofSize: 30, weight: .bold)
        pwField.font = .systemFont(ofSize: 30, weight: .bold)
        idField.placeholder = "이메일을 입력해주세요"
        pwField.placeholder = "비밀번호를 입력해주세요"
        
        loginButton.isEnabled = false //초기값
        loginButton.tintColor = .systemGray
        loginButton.backgroundColor = .systemGray
        loginButton.setTitle("비활성화 상태", for: .normal)
        loginButton.addTarget(self, action: #selector(showNextView), for: .touchDown)
        
        idValidView.backgroundColor = .red
        idValidView.layer.cornerRadius = 10
        
        pwValidView.backgroundColor = .red
        pwValidView.layer.cornerRadius = 10
    }
    
    @objc func showNextView() {
        self.show(SuccessView(), sender: nil)
    }
    
    private func layout() {
    
        [idField, pwField, loginButton, idValidView, pwValidView]
            .forEach {
                view.addSubview($0)
            }
        
        idField.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
        
        pwField.snp.makeConstraints {
            $0.leading.trailing.equalTo(idField)
            $0.top.equalTo(idField.snp.bottom).offset(15)
            $0.height.equalTo(idField)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(pwField.snp.bottom).offset(15)
            $0.leading.trailing.equalTo(idField)
            $0.height.equalTo(80)
        }
        
        idValidView.snp.makeConstraints {
            $0.height.width.equalTo(10)
            $0.trailing.equalTo(idField.snp.trailing).inset(10)
            $0.top.equalTo(idField.snp.top).inset(20)
        }
        
        pwValidView.snp.makeConstraints {
            $0.height.width.equalTo(10)
            $0.trailing.equalTo(pwField.snp.trailing).inset(10)
            $0.top.equalTo(pwField.snp.top).inset(20)
        }
    }
    
    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }

    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
}
