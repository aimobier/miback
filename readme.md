模仿小米的返回按钮

![miback preview](Kapture%202018-09-03%20at%2017.14.43.gif "miback preview")

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
