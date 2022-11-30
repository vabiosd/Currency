//
//  ViewController.swift
//  Currency Converter
//
//  Created by vaibhav singh on 29/11/22.
//

import UIKit
import RxSwift
import RxCocoa

final class CurrencyConversionViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    /// ViewModelFactory responsible for initialising a viewModel with uiInputs from the viewController
    var viewModelFactory: (CurrencyConversionViewModel.UIInputs) -> CurrencyConversionViewModel = { _ in
        fatalError("A factory must be provided")
    }
    
    //MARK: View properties
    
    private var errorView: UILabel = {
        let errorView = UILabel()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.textAlignment = .center
        errorView.isHidden = true
        errorView.font = UIFont.boldSystemFont(ofSize: 16)
        errorView.textColor = .systemRed
        errorView.numberOfLines = 0
        return errorView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.backgroundColor = .lightGray
        activityIndicatorView.color = .white
        return activityIndicatorView
    }()
    
    private var baseCurrencyDropDown: UIPickerView = {
        let dropDown = UIPickerView()
        dropDown.translatesAutoresizingMaskIntoConstraints = false
        return dropDown
    }()
    
    private var conversionCurrencyDropDown: UIPickerView = {
        let dropDown = UIPickerView()
        dropDown.translatesAutoresizingMaskIntoConstraints = false
        return dropDown
    }()
    
    private var fromTextfield: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "From"
        textField.textAlignment = .center
        return textField
    }()
    
    private var fromLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "From Currency"
        return label
    }()
    
    private var toLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "To Currency"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var toTextfield: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "To"
        textField.textAlignment = .center
        return textField
    }()
    
    private var convertedAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .systemGray6
        return label
    }()
    
    private var baseAmountTextfield: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.placeholder = "Enter amount"
        textField.backgroundColor = .systemGray6
        return textField
    }()
    
    //MARK: Lifycycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        bindViews()
        setupComponents()
        setupConstraints()
    }

    //MARK: Setup ViewModel

    private func setupViewModel() {
        /// Initialising viewModel with UIInputs from the textfield, these include to, from currencies and the amount
        let uiInputs = CurrencyConversionViewModel.UIInputs(baseCurrency: fromTextfield.rx.text
                                                                .orEmpty
                                                                .distinctUntilChanged()
                                                                .asDriver(onErrorJustReturn: "")
                                                                .debounce(RxTimeInterval.milliseconds(500)),
                                                            conversionCurrency: toTextfield.rx.text
                                                                .orEmpty
                                                                .distinctUntilChanged()
                                                                .asDriver(onErrorJustReturn: "")
                                                                .debounce(RxTimeInterval.milliseconds(500)),
                                                            amount: baseAmountTextfield.rx.text
                                                                .orEmpty
                                                                .distinctUntilChanged()
                                                                .asDriver(onErrorJustReturn: "")
                                                                .debounce(RxTimeInterval.milliseconds(500)))
        let viewModel = viewModelFactory(uiInputs)
        bindViewModel(viewModel: viewModel)
    }
    
    private func bindViewModel(viewModel: CurrencyConversionViewModel) {
        /// Binding viewModel outputs to populate views
        viewModel.stateRelay.asDriver()
            .drive(onNext: { [weak self] state in
                /// Updating UI based on state!
                switch state {
                case .loading:
                    self?.setLoadingUI()
                case .loaded:
                    self?.setLoadedUI()
                case .errorFetchingCurrencies(let error):
                    self?.setErrorUI(errorString: error, currenciesAvailable: false)
                case .errorDoingConversion(let error):
                    self?.setErrorUI(errorString: error, currenciesAvailable: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.currencies
            .share()
            .observe(on: MainScheduler.instance)
            .bind(to: baseCurrencyDropDown.rx.itemTitles) { (_, currency) in
                return currency
            }
            .disposed(by: disposeBag)
        
        viewModel.currencies
            .share()
            .observe(on: MainScheduler.instance)
            .bind(to: conversionCurrencyDropDown.rx.itemTitles) { (_, currency) in
                return currency
            }
            .disposed(by: disposeBag)
        
        viewModel.convertedAmount
            .bind(to: convertedAmountLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    /// Binding textfields to picker views
    private func bindViews() {
        baseCurrencyDropDown.rx.modelSelected(String.self)
                    .subscribe(onNext: { currencySelected in
                        self.fromTextfield.text = currencySelected.first!
                        self.fromTextfield.endEditing(true)
                    })
                    .disposed(by: disposeBag)
        
        conversionCurrencyDropDown.rx.modelSelected(String.self)
                    .subscribe(onNext: { currencySelected in
                        self.toTextfield.text = currencySelected.first!
                        self.toTextfield.endEditing(true)
                    })
                    .disposed(by: disposeBag)
    }
    
    //MARK: Setup Views
    
    private func setupComponents() {
        view.backgroundColor = .white
        
        fromTextfield.inputView = baseCurrencyDropDown
        toTextfield.inputView = conversionCurrencyDropDown
        
        baseAmountTextfield.keyboardType = .numberPad
        
        [fromLabel, fromTextfield, toLabel, toTextfield, activityIndicator, baseAmountTextfield, convertedAmountLabel, errorView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 80),
            activityIndicator.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            fromLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80),
            fromLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            fromLabel.widthAnchor.constraint(equalToConstant: 100),
            fromLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            fromTextfield.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80),
            fromTextfield.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 8),
            fromTextfield.widthAnchor.constraint(equalToConstant: 80),
            fromTextfield.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            toLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80),
            toLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            toLabel.widthAnchor.constraint(equalToConstant: 100),
            toLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            toTextfield.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80),
            toTextfield.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 8),
            toTextfield.widthAnchor.constraint(equalToConstant: 80),
            toTextfield.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            baseAmountTextfield.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80),
            baseAmountTextfield.topAnchor.constraint(equalTo: fromTextfield.bottomAnchor, constant: 16),
            baseAmountTextfield.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            convertedAmountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80),
            convertedAmountLabel.topAnchor.constraint(equalTo: toTextfield.bottomAnchor, constant: 16),
            convertedAmountLabel.widthAnchor.constraint(equalToConstant: 80),
            convertedAmountLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64),
            errorView.widthAnchor.constraint(equalToConstant: 120)
        ])
        
    }
    
    //MARK: UI updates based on state
    
    private func setLoadingUI() {
        activityIndicator.startAnimating()
        errorView.isHidden = true
        baseAmountTextfield.isUserInteractionEnabled = false
        toTextfield.isUserInteractionEnabled = false
        fromTextfield.isUserInteractionEnabled = false
    }
    
    private func setLoadedUI() {
        activityIndicator.stopAnimating()
        errorView.isHidden = true
        baseAmountTextfield.isUserInteractionEnabled = true
        toTextfield.isUserInteractionEnabled = true
        fromTextfield.isUserInteractionEnabled = true
    }
    
    private func setErrorUI(errorString: String, currenciesAvailable: Bool) {
        activityIndicator.stopAnimating()
        errorView.isHidden = false
        baseAmountTextfield.isUserInteractionEnabled = currenciesAvailable
        toTextfield.isUserInteractionEnabled = currenciesAvailable
        fromTextfield.isUserInteractionEnabled = currenciesAvailable
        errorView.text = errorString
    }
}

