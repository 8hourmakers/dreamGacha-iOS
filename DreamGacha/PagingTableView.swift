//
//  PagingTableView.swift
//  kuchelin
//
//  Created by Noverish Harold on 2017. 5. 13..
//  Copyright © 2017년 hyoni. All rights reserved.
//
import UIKit
import Foundation

class PagingTableView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    weak var nowVC: UIViewController!
    weak var dataSource: PagingTableViewDataSource!
    weak var delegate: PagingTableViewDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noResultLayout: UIView!
    
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

    var columnNum = 1
    var sectionInset = CGFloat(0)
    var itemSpacing = CGFloat(0)
    
    var items:[Any] = []
    var page:Int = 1
    var isLastPage:Bool = false
    var isLoading:Bool = false
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    func initialize(nowVC: UIViewController, dataSource: PagingTableViewDataSource) {
        let xibName = String(describing: PagingTableView.self)
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        self.nowVC = nowVC
        self.dataSource = dataSource
        
        let nibName = dataSource.getNibName()
        collectionView.addSubview(refreshControl)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        
        refresh()
    }
    
    func refresh() {
        page = 0
        items = []
        isLastPage = false
        
        loadNextPage()
    }
    
    func loadNextPage() {
        isLoading = true
        page += 1
        
        dataSource.loadMoreItems(page: page) { (newItems) in
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
            }
            
            self.isLoading = false
            self.refreshControl.endRefreshing()
        }
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        refresh()
    }
    
    public func scrollTop() {
        collectionView.setContentOffset(CGPoint(0, 0), animated: true)
    }
    
    //[DataSource] start
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = dataSource.getNibName()
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath)
        
        if(indexPath.row < self.items.count) {
            cell = dataSource.setItem(cell: cell, item: self.items[indexPath.row])
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
        guard let delegate = delegate else {
            return
        }

        if(indexPath.row >= self.items.count) {
            return
        }

        delegate.didSelected?(item: self.items[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let delegate = delegate,
              let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }

        if(indexPath.row >= self.items.count) {
            return
        }

        delegate.didHighlighted?(
                isHighlighted: true,
                cell: cell,
                item: self.items[indexPath.row]
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let delegate = delegate,
              let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }

        if(indexPath.row >= self.items.count) {
            return
        }

        delegate.didHighlighted?(
                isHighlighted: true,
                cell: cell,
                item: self.items[indexPath.row]
        )
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
    
    //[Cell Size and Space] start
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(indexPath.row < self.items.count) {
            var tmp = collectionView.bounds.size.width
            tmp -= CGFloat(2) * sectionInset
            tmp -= CGFloat(columnNum - 1) * itemSpacing
            
            let cellWidth = tmp / CGFloat(columnNum)
            let cellHeight = dataSource.calcHeight(width: cellWidth, item: items[indexPath.row])
            
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        return CGSize(width:200, height: 200)
    }
    //[Cell Size and Space] end
}

@objc protocol PagingTableViewDataSource: class {
    func getNibName() -> String
    func loadMoreItems(page:Int, callback: @escaping ([Any]) -> Void)
    func setItem(cell: UICollectionViewCell, item: Any) -> UICollectionViewCell
    func calcHeight(width: CGFloat, item: Any) -> CGFloat
}

@objc protocol PagingTableViewDelegate: class {
    @objc optional func didSelected(item: Any)
    @objc optional func didHighlighted(isHighlighted:Bool, cell:UICollectionViewCell, item: Any)
}
