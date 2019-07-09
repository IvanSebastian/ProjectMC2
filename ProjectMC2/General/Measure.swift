//
//  Measure.swift
//  ProjectMC2
//
//  Created by Randy Noel on 08/07/19.
//  Copyright © 2019 whiteHat. All rights reserved.
//

import UIKit

protocol MeasureDelegate{
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int)
}

class Measure{
    var delegate: MeasureDelegate?
    
    var index: Int = -1
    var measurements: [Dictionary<String, Double>]
    
    init() {
        let measurement = [
            "start": CACurrentMediaTime(),
            "end":CACurrentMediaTime()
        ]
        measurements = Array<Dictionary<String,Double>>(repeating: measurement, count: 30)
    }
    
    func recordStart(){
        index += 1
        index %= 30
        measurements[index] = [:]
        
        tag(for: index, with: "start")
    }
    
    func recordStop(){
        tag(for: index, with: "end")
        
        let beforeMeasurement = getBeforeMeasurement(for: index)
        let currentMeasurement = measurements[index]
        if let startTime = currentMeasurement["endInference"], let endInferenceTime = currentMeasurement["endInference"], let endTime = currentMeasurement["end"], let beforeStartTime = beforeMeasurement["start"]{
            delegate?.updateMeasure(inferenceTime: endInferenceTime - startTime, executionTime: endTime - startTime, fps: Int(1/(startTime - beforeStartTime)))
        }
    }
    
    func tag(with msg: String? = ""){
        tag(for: index, with: msg)
    }
    
    private func tag(for index: Int, with msg:String? = " "){
        if let message = msg {
            measurements[index][message] = CACurrentMediaTime()
        }
    }
    
    private func getBeforeMeasurement(for index: Int) -> Dictionary<String, Double>{
        return measurements[(index + 30 - 1 ) % 30]
    }
}

class MeasureLogView: UIView {
    let estimateLabel = UILabel(frame: .zero)
    let fpsLabel = UILabel(frame: .zero)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init has not been implemented")
    }
}
