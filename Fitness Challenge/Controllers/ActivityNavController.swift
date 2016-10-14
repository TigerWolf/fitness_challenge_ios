import UIKit

class ActivityNavController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let controllers = [ActivityViewController()]
        self.viewControllers = controllers
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
