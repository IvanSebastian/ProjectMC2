//
//  ViewController.swift
//  ProjectMC2
//
//  Created by Randy Noel on 08/07/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit
import Vision
import CoreMedia

class ViewController: UIViewController {
    public typealias DetectObjectsCompletion = ([PredictedPoint?]?, Error?) -> Void
    @IBOutlet weak var jointCamera: UIView!
    
    let measure = Measure()
    
    var videoCapture = VideoCapture()
    
    typealias EstimateModel = model_cpm
    
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    
    var postProcessor: HeatmapPostProcessor = HeatmapPostProcessor()
    var mvfilters: [MovingAverageFilter] = []
    
    private var tableData: [PredictedPoint?] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    //setUpModel
    func setUpModel(){
        if let visionModel = try? VNCoreMLModel(for: EstimateModel().model){
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionReques)
        }
    }

}

extension ViewController {
    
    func predicUsingVision(pixelBuffer : CVPixelBuffer){
        guard let request = request else {fatalError()}
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    func visionRequestDidComplete(request: VNRequest,)
}
