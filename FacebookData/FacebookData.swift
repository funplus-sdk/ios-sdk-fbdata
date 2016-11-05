//
//  FacebookData.swift
//  FacebookData
//
//  Created by Yuankun Zhang on 18/10/2016.
//  Copyright © 2016 funplus. All rights reserved.
//

import Foundation
import FunPlusSDK
import FacebookCore

///
/// Export Data events to Facebook events
///
public class FacebookData : DataEventTracedListener {
    
    static var instance: FacebookData?
    static var shared = { return instance! }()
    
    public class func install(dataTracer: FunPlusData) {
        if instance == nil {
            SDKApplicationDelegate.shared.application(UIApplication.shared)
            AppEventsLogger.activate()
            instance = FacebookData()
            dataTracer.registerEventTracedListener(listener: instance!)
        
            print("[FacebookData] FacebookData ready to work")
        } else {
            print("[FacebookData] FacebookData has been installed, there's no need to install it again")
        }
    }
    
    public func kpiEventTraced(event: [String: Any]) {
        convertDataEventToFacebookEvent(dataEvent: event)
        print("[FacebookData] Received KPI event: \(event["event"])")
    }
    
    public func customEventTraced(event: [String: Any]) {
        convertDataEventToFacebookEvent(dataEvent: event)
        print("[FacebookData] Received custom event: \(event["event"])")
    }
    
    func convertDataEventToFacebookEvent(dataEvent: [String: Any]) {
        guard
            let eventName = dataEvent["event"] as? String,
            let properties = dataEvent["properties"] as? [String: Any]
        else {
            return
        }
        
        switch eventName {
        case "tutorial":
            if let success = properties["success"] as? Int, let contentId = properties["content_id"] as? String {
                logCompletedTutorial(success: success, contentId: contentId)
            }
        case "level":
            if let level = properties["level"] as? String {
                logAchievedLevel(level: level)
            }
        default: break
        }
    }
    
    func logCompletedTutorial(success: Int, contentId: String) {
        let parameters: AppEvent.ParametersDictionary = [
            AppEventParameterName.successful: success,
            AppEventParameterName.contentId: contentId
        ]
        AppEventsLogger.log(AppEvent.completedTutorial().name.rawValue, parameters: parameters)
    }
    
    func logAchievedLevel(level: String) {
        let parameters: AppEvent.ParametersDictionary = [
            AppEventParameterName.level: level
        ]
        AppEventsLogger.log(AppEvent.achievedLevel().name.rawValue, parameters: parameters)
    }
}
