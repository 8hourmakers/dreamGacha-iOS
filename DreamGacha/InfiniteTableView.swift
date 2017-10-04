//
//  InfiniteTableView.swift
//
//  Created by Noverish Harold on 2017. 5. 13..
//  Copyright © 2017년 Noverish. All rights reserved.
//  https://gist.github.com/Noverish/82b9cbb6a091bcbf4ff22ca0921c726d
//
import UIKit
import Foundation

class InfiniteTableView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    let DEFAULT_CELL_HEIGHT = CGFloat(100)
    let DEFAULT_COLUMN_NUM = 1
    private let IDENTIFIER = "cell"
    private var nibHeight: CGFloat = 0
    private var dataSource: InfiniteTableViewDataSource!
    var delegate: InfiniteTableViewDelegate?
    
    private(set) var collectionView: UICollectionView!
    private(set) var noResultLayout: UIView!
    var collectionViewFlowLayout:UICollectionViewFlowLayout {
        get {
            return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        }
    }
    
    var header:UIView?
    var footer:UIView?
    var noResultView:UIView? {
        get {
            return noResultLayout.subviews.first
        }
        set (view) {
            noResultLayout.subviews.first?.removeFromSuperview()
            
            if let view = view {
                noResultLayout.addSubview(view)
            }
        }
    }
    
    private(set) var originItems:[Any] = []
    private(set) var items:[Any] = []
    private(set) var page:Int = 1
    private(set) var isLastPage:Bool = false
    private(set) var isLoading:Bool = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let insideFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        self.collectionView = UICollectionView(frame: insideFrame, collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionView.backgroundColor = .clear
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.addSubview(refreshControl)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: IDENTIFIER)
        
        self.collectionViewFlowLayout.minimumLineSpacing = CGFloat(0)
        self.collectionViewFlowLayout.minimumInteritemSpacing = CGFloat(0)
        
        self.noResultLayout = UIView(frame: insideFrame)
        self.noResultLayout.backgroundColor = .clear
        
        self.addSubview(noResultLayout)
        self.addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insideFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        self.collectionView.frame = insideFrame
        self.noResultView?.frame = insideFrame
    }
    
    public func initiate(nibName: String, dataSource: InfiniteTableViewDataSource) {
        self.dataSource = dataSource
        self.nibHeight = (Bundle.main.loadNibNamed(nibName, owner: self)?.first as? UIView)?.frame.height ?? DEFAULT_CELL_HEIGHT
        self.collectionView.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: IDENTIFIER)
        
        self.refresh()
    }
    
    public func refresh() {
        page = 0
        items = []
        isLastPage = false
        
        loadNextPage()
    }
    
    public func loadNextPage() {
        isLoading = true
        page += 1
        
        dataSource.infiniteTableView(self, itemsOn: page) { (newItems) in
            if(newItems.count == 0) {
                self.isLastPage = true
            }
            
            self.items.append(contentsOf: newItems)
            DispatchQueue.main.async {
                if(newItems.count == 0 && self.page == 1) {
                    self.noResultLayout.isHidden = false
                } else {
                    self.noResultLayout.isHidden = true
                    self.collectionView.reloadData()
                }
                
                self.isLoading = false
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    public func scrollTop() {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    public func insertItem(_ item: Any) {
        items.append(item)
        collectionView.reloadData()
    }
    
    public func modifyItem(_ item: Any) {
        guard let index = items.index(where: {
            dataSource.infiniteTableView(self, item: $0, isEqualTo: item)
        }) else {
            return
        }
        
        items[index] = item
        collectionView.reloadData()
    }
    
    public func deleteItem(_ item: Any) {
        guard let index = items.index(where: {
            dataSource.infiniteTableView(self, item: $0, isEqualTo: item)
        }) else {
            return
        }
        
        items.remove(at: index)
        collectionView.reloadData()
    }
    
    public func setFilter(_ filter: ((Any) -> Bool)?) {
        guard let filter = filter else {
            if(originItems.count > 0) {
                items.removeAll()
                items.append(contentsOf: originItems)
                originItems.removeAll()
                collectionView.reloadData()
            }
            return
        }
        
        originItems.append(contentsOf: items)
        items.removeAll()
        
        for item in originItems {
            if(filter(item)) {
                items.append(item)
            }
        }
        
        collectionView.reloadData()
    }
    
    //[DataSource] start
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: IDENTIFIER, for: indexPath)
        
        if(indexPath.row < self.items.count) {
            cell = dataSource.infiniteTableView(self, set: cell, for: items[indexPath.row])
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            if(!isLastPage && !isLoading){
                loadNextPage()
            }
        }
    }
    //[DataSource] end
    //[item selection start]
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if(indexPath.row >= self.items.count) { return }
        
        delegate?.infiniteTableView?(self, didSelectItemAt: indexPath, item: items[indexPath.row], cell: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if(indexPath.row >= self.items.count) { return }
        
        delegate?.infiniteTableView?(self, didHighlightItemAt: indexPath, item: items[indexPath.row], cell: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        if(indexPath.row >= self.items.count) { return }
        
        delegate?.infiniteTableView?(self, didUnhighlightItemAt: indexPath, item: items[indexPath.row], cell: cell)
    }
    //[item selection end]
    //[Header and Footer] start
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            if let header = self.header {
                headerView.addSubview(header)
            }
            return headerView
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            if let footer = self.footer {
                footerView.addSubview(footer)
            }
            return footerView
            
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if let header = header {
            header.frame.size = CGSize(width: collectionView.frame.width, height: header.frame.height)
            return header.frame.size
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if let footer = footer {
            footer.frame.size = CGSize(width: collectionView.frame.width, height: footer.frame.height)
            return footer.frame.size
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    //[Header and Footer] end
    //[Cell Size] start
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let columnNum = dataSource.infiniteTableView?(numberOfColumnsOf: self) ?? DEFAULT_COLUMN_NUM
        var cellWidth = collectionView.bounds.size.width
        cellWidth -= self.collectionViewFlowLayout.sectionInset.left
        cellWidth -= self.collectionViewFlowLayout.sectionInset.right
        cellWidth -= CGFloat(columnNum - 1) * self.collectionViewFlowLayout.minimumInteritemSpacing
        cellWidth /= CGFloat(columnNum)
        
        var cellHeight:CGFloat?
        if(indexPath.row < self.items.count) {
            cellHeight = dataSource.infiniteTableView?(self, cellHeightOf: items[indexPath.row], cellWidth: cellWidth)
        }
        
        return CGSize(width: cellWidth, height: cellHeight ?? nibHeight)
    }
    //[Cell Size] end
}

@objc protocol InfiniteTableViewDataSource: class {
    func infiniteTableView(_ infiniteTableView: InfiniteTableView, itemsOn page: Int, callback: @escaping ([Any]) -> Void)
    func infiniteTableView(_ infiniteTableView: InfiniteTableView, set cell: UICollectionViewCell, for item: Any) -> UICollectionViewCell
    func infiniteTableView(_ infiniteTableView: InfiniteTableView, item lhs: Any, isEqualTo rhs: Any) -> Bool
    @objc optional func infiniteTableView(numberOfColumnsOf infiniteTableView: InfiniteTableView) -> Int
    @objc optional func infiniteTableView(_ infiniteTableView: InfiniteTableView, cellHeightOf item: Any, cellWidth: CGFloat) -> CGFloat
}

@objc protocol InfiniteTableViewDelegate: class {
    @objc optional func infiniteTableView(_ infiniteTableView: InfiniteTableView, didSelectItemAt indexPath: IndexPath, item: Any, cell: UICollectionViewCell)
    @objc optional func infiniteTableView(_ infiniteTableView: InfiniteTableView, didHighlightItemAt indexPath: IndexPath, item: Any, cell: UICollectionViewCell)
    @objc optional func infiniteTableView(_ infiniteTableView: InfiniteTableView, didUnhighlightItemAt indexPath: IndexPath, item: Any, cell: UICollectionViewCell)
}
