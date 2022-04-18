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
    let textView = UITextView()
    
    let jsonlink = "http://headers.jsontest.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind(viewModel)
        attribute()
        layout()
    }
    
    func bind(_ viewModel: MainViewModel) {
        
        //Input
        idField.rx.text.orEmpty
            .bind(to: viewModel.idInputText)
            .disposed(by: disposeBag)
        
        viewModel.idInputText
            .map(viewModel.checkEmailValid(_:))
            .bind(to: viewModel.idValid)
            .disposed(by: disposeBag)
        
        pwField.rx.text.orEmpty
            .bind(to: viewModel.pwInputText)
            .disposed(by: disposeBag)
        
        viewModel.pwInputText
            .map(viewModel.checkPasswordValid(_:))
            .bind(to: viewModel.pwValid)
            .disposed(by: disposeBag)

        loginButton.rx.tap
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .flatMap { () -> Observable<String?> in
                return viewModel.downloadJson(URLs: self.jsonlink)
            }
            .bind(to: viewModel.jsonSub)
            .disposed(by: disposeBag)
            
        //Output
        viewModel.idValid
            .subscribe(onNext: { b in
                self.idValidView.isHidden = b
            })
            .disposed(by: disposeBag)
        
        viewModel.pwValid
            .subscribe(onNext: { b in
                self.pwValidView.isHidden = b
            })
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                viewModel.idValid,
                viewModel.pwValid,
                resultSelector: { $0 && $1 }
            )
            .subscribe(onNext: { b in
                switch b {
                case true:
                    self.loginButton.isEnabled = b
                    self.loginButton.setTitle("로그인", for: .normal)
                case false:
                    self.loginButton.isEnabled = b
                    self.loginButton.setTitle("입력정보 확인", for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.jsonSub
            .subscribe(onNext: { text in
                DispatchQueue.main.async {
                    self.textView.text = text
                }
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
        loginButton.setTitle("입력정보 확인", for: .normal)
        //loginButton.addTarget(self, action: #selector(showNextView), for: .touchDown)
        
        idValidView.backgroundColor = .red
        idValidView.layer.cornerRadius = 10
        
        pwValidView.backgroundColor = .red
        pwValidView.layer.cornerRadius = 10
        
        textView.backgroundColor = .white
    }
    
    @objc func showNextView() {
        self.show(SuccessView(), sender: nil)
    }
    
    private func layout() {
    
        [idField, pwField, loginButton, idValidView, pwValidView, textView]
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
        
        textView.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(25)
            $0.leading.trailing.equalTo(idField)
            $0.height.equalTo(250)
        }
    }

}
