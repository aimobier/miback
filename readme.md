模仿小米的返回按钮

![](Kapture 2018-09-03 at 17.14.43.gif)

## 使用

````swift
class ViewController: UIViewController,MIBackGestureRecognizerProtocol {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.miBackInitialization()
    }

    func miBackDidBack() {
        
        self.dismiss(animated: true, completion: nil)
    }
}
````