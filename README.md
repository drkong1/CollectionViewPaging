# CollectionViewPaging

```
collectionView.decelerationRate = .fast


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
```



# ScreenShot
![image](https://github.com/drkong1/CollectionViewPaging/blob/master/paging.gif)


# Library
use Sapkit
https://github.com/SnapKit/SnapKit


