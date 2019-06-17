//
//  TrendViewController.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import SafariServices
import UIKit

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

class TrendViewController: BaseViewController, StoryboardView, ReactorBased {
    
    typealias Reactor = TrendViewReactor
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Properties
    static var dataSource: RxTableViewSectionedReloadDataSource<TrendSection> {
        return .init(configureCell: { (datasource, tableView, indexPath, sectionItem) -> UITableViewCell in
            switch sectionItem {
            case .trendingRepos(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: TrendingRepositoryCell.self)
                cell.reactor = reactor
                return cell
            case .trendingDevelopers(let reactor):
                let cell = tableView.dequeueReusableCell(for: indexPath, cellType: TrendingDeveloperCell.self)
                let rank = indexPath.row
                cell.reactor = reactor
                cell.reactor?.action.onNext(.initRank(rank))
                return cell
            }
        })
    }
    private lazy var dataSource: RxTableViewSectionedReloadDataSource<TrendSection> = type(of: self).dataSource
    
    private var periodActions: [RxAlertAction<String>] {
        var actions = [RxAlertAction<String>]()
        PeriodTypes.allCases.forEach { type in
            let action = RxAlertAction<String>(title: type.buttonTitle(), style: .default, result: type.rawValue)
            actions.append(action)
        }
        let cancelAction = RxAlertAction<String>(title: "Cancel", style: .cancel, result: "")
        actions.append(cancelAction)
        return actions
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    fileprivate func configureUI() {
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNib(cellType: TrendingRepositoryCell.self)
        tableView.registerNib(cellType: TrendingDeveloperCell.self)

        tableView.refreshControl = refreshControl
        
        TrendTypes.allCases.enumerated().forEach { (index, type) in
            segmentControl.setTitle(type.segmentTitle, forSegmentAt: index)
        }
    }
    
    // MARK: - Configure
    func bind(reactor: Reactor) {
        
        // Action
        Observable.just(Void())
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        segmentControl.rx.controlEvent(.valueChanged)
            .map { _ in Reactor.Action.switchSegmentControl }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        periodButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let sheet = UIAlertController.rx_presentAlert(viewController: self,
                                                              preferredStyle: .actionSheet,
                                                              animated: true,
                                                              actions: self.periodActions)
                sheet.subscribe(onNext: { selectedPeriod in
                    guard let period = PeriodTypes(rawValue: selectedPeriod) else { return }
                    reactor.action.onNext(.selectPeriod(period))
                }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
        
        languageButton.rx.tap
            .flatMap { [weak self] _ -> Observable<Language> in
                guard let self = self else { return .empty() }
                let languageReactor = LanguagesViewReactor(languagesService: LanguagesService(),
                                                           userDefaultsService: UserDefaultsService())
                let languageVC = LanguagesViewController.instantiate(withReactor: languageReactor)
                self.present(languageVC.navigationWrap(), animated: true, completion: nil)
                return languageVC.selectedLanguage
            }.subscribe(onNext: { language in
                let languageName = language.type != .all ? language.name : LanguageTypes.all.buttonTitle()
                reactor.action.onNext(.selectLanguage(languageName))
            }).disposed(by: self.disposeBag)
        
        // State
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating )
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.period }
            .map { $0.buttonTitle() }
            .bind(to: periodButton.rx.title())
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.language }
            .filterNil()
            .bind(to: languageButton.rx.title())
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.trendSections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        // View
        tableView.rx.itemSelected(dataSource: dataSource)
            .subscribe(onNext: { [weak self] sectionItem in
                guard let self = self else { return }
                switch sectionItem {
                case .trendingRepos(let reactor):
                    self.goToWebVC(urlString: reactor.currentState.url)
                case .trendingDevelopers(let reactor):
                    self.goToWebVC(urlString: reactor.currentState.url)
                }
                // log.debug(sectionItem)
            }).disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)
    }
    
    // MARK: Go To
    fileprivate func goToWebVC(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}