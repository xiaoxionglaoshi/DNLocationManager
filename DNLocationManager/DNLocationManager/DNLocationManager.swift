//
//  DNLocationManager.swift
//  DNLocationManager
//
//  Created by mainone on 16/10/12.
//  Copyright © 2016年 wjn. All rights reserved.
//

import UIKit
import CoreLocation

public typealias userCLLocation = ((_ location: CLLocation?) -> Void)
public typealias cityString = ((_ city: String? ) -> Void)


private let locationManagerShareInstance = DNLocationManager()

class DNLocationManager: NSObject, CLLocationManagerDelegate {
    // 创建一个单例
    open class var shared: DNLocationManager {
        return locationManagerShareInstance
    }
    
    // 定义闭包变量
    private var onUserCLLocation: userCLLocation?
    private var onCityString: cityString?
    
    open func getCity(city: @escaping cityString) {
        startLocation()
        onCityString = city
    }
    
    open func getUserCLLocation(cllocation: @escaping userCLLocation) {
        startLocation()
        onUserCLLocation = cllocation
    }
    
    
    // 创建一个CLLocationManager对象
    private var locationManager: CLLocationManager!
    // 创建一个CLGeocoder对象
    private var geocoder: CLGeocoder!
    
    override init() {
        super.init()
        
        // 初始化locationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //定位精准度
        locationManager.distanceFilter = 100 // 超出范围更新位置信息
        if Double(UIDevice.current.systemVersion)! >= 8.0 {
            locationManager.requestWhenInUseAuthorization() // 使用期间
        }
        // 初始化geocoder
        geocoder = CLGeocoder()
    }
    
    // 定位功能开启
    func startLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("每当请求到位置信息时都会调用此方法")
        if let location = locations.first { // 坐标
            if onUserCLLocation != nil {
                onUserCLLocation!(location)
            }
            
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.first {
                    if self.onCityString != nil {
                        self.onCityString!(placemark.locality)
                    }
                }
            }
        }
        // 不需要定位的时候停止定位
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("用户未决定")
        case .restricted: // 暂时没啥用
            print("访问受限")
        case .denied: // /定位关闭时和对此APP授权为never时调用
            print("用户未决定")
        case .authorizedAlways:
            print("获取前后台定位授权")
        case .authorizedWhenInUse:
            print("获取前台定位授权")
        }
    }
}
    
