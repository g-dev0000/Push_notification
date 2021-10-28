//
//  NotificationButtonModel.swift
//  awesome_notifications
//
//  Created by Rafael Setragni on 05/09/20.
//

import Foundation

public class NotificationButtonModel : AbstractModel {
    
    var key:String?
    var icon:String?
    var label:String?
    var enabled:Bool?
    var autoDismissable:Bool?
    var buttonType:ActionButtonType?
    
    public func fromMap(arguments: [String : Any?]?) -> AbstractModel? {
        if(arguments == nil){ return self }
       
        self.key        = MapUtils<String>.getValueOrDefault(reference: "key", arguments: arguments)
        self.icon       = MapUtils<String>.getValueOrDefault(reference: "icon", arguments: arguments)
        self.label      = MapUtils<String>.getValueOrDefault(reference: "label", arguments: arguments)
        self.enabled    = MapUtils<Bool>.getValueOrDefault(reference: "enabled", arguments: arguments)
        self.autoDismissable = MapUtils<Bool>.getValueOrDefault(reference: "autoDismissable", arguments: arguments)
        
        self.buttonType = EnumUtils<ActionButtonType>.getEnumOrDefault(reference: "buttonType", arguments: arguments)
        
        return self
    }
    
    public func toMap() -> [String : Any?] {
        var mapData:[String: Any?] = [:]
        
        if(key != nil) {mapData["key"] = self.key}
        if(icon != nil) {mapData["icon"] = self.icon}
        if(label != nil) {mapData["label"] = self.label}
        if(enabled != nil) {mapData["enabled"] = self.enabled}
        if(autoDismissable != nil) {mapData["autoDismissable"] = self.autoDismissable}
        
        if(buttonType != nil) {mapData["buttonType"] = self.buttonType?.rawValue}
        
        return mapData
    }
    
    public func validate() throws {
        
        if(StringUtils.isNullOrEmpty(key)){
            throw AwesomeNotificationsException.invalidRequiredFields(
                msg: "Button action key cannot be null or empty")
        }

        if(StringUtils.isNullOrEmpty(label)){
            throw AwesomeNotificationsException.invalidRequiredFields(
                msg: "Button label cannot be null or empty")
        }
    }
}
