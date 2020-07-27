//
//  ViewController.swift
//
// Copyright (c) 2020 Hunjong Bong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

import SnapKit


class ViewController: UIViewController {
    
    static let left: CGFloat = 30
    static let right: CGFloat = 30
    static let lineSpacing: CGFloat = 10
    
    private var pagingCollectionView: UICollectionView?
    private var dragStartPoint: CGPoint = .zero
    private var currentPage: Int = 0
    private var numberOfPages: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .gray
        self.setup()
        
        self.numberOfPages = 5
        self.pagingCollectionView?.reloadData()
    }
}


extension ViewController {
    
    private func setup() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .cyan
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
            make.height.equalTo(200)
        }
        collectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        collectionView.decelerationRate = .fast
        self.pagingCollectionView = collectionView
        
        let verticalLeftLine = UIView()
        verticalLeftLine.backgroundColor = .black
        self.view.addSubview(verticalLeftLine)
        verticalLeftLine.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(ViewController.left)
            make.width.equalTo(1)
        }
        
        let verticalRightLine = UIView()
        verticalRightLine.backgroundColor = .black
        self.view.addSubview(verticalRightLine)
        verticalRightLine.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-ViewController.left)
            make.width.equalTo(1)
        }
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: ViewController.left, bottom: 0, right: ViewController.right)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ViewController.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (UIScreen.main.bounds.size.width - ViewController.left - ViewController.right)
        return CGSize(width: cellWidth, height: 50)
    }
}


extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as? MyCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        }
        
        cell.bindData(indexPath.item)
        return cell
    }
}


// paging
extension ViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dragStartPoint = scrollView.contentOffset
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        let pageWidth = UIScreen.main.bounds.size.width - ViewController.left - ViewController.right + ViewController.lineSpacing
        
        if scrollView.contentOffset.x == targetContentOffset.pointee.x { // no decelerate
            if fabsf(Float(self.dragStartPoint.x - scrollView.contentOffset.x)) > 40 { // min move distance = 40
                let dragLeft = self.dragStartPoint.x < scrollView.contentOffset.x
                if dragLeft {
                    self.currentPage = isRTL ? self.currentPage - 1 : self.currentPage + 1
                } else {
                    self.currentPage = isRTL ? self.currentPage + 1 : self.currentPage - 1
                }
            }
        } else if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            let maxRight = scrollView.contentSize.width - UIScreen.main.bounds.size.width
            if scrollView.contentOffset.x <= maxRight { // not right bounce
                self.currentPage = isRTL ? self.currentPage + 1 : self.currentPage - 1
            }
        } else {
            if scrollView.contentOffset.x >= 0 { // not left bounce
                self.currentPage = isRTL ? self.currentPage - 1 : self.currentPage + 1
            }
        }
        
        self.currentPage = max(0, self.currentPage)
        self.currentPage = min(self.numberOfPages - 1, self.currentPage)
        
        var offset = targetContentOffset.pointee
        if isRTL {
            offset.x = CGFloat(self.numberOfPages - self.currentPage - 1) * pageWidth
        } else {
            offset.x = CGFloat(self.currentPage) * pageWidth
        }
        targetContentOffset.pointee = offset
    }
}
