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
public typealias CLLocationError = ((_ error: Error? ) -> Void)
public typealias cityError = ((_ error: Error? ) -> Void)

private let locationManagerShareInstance = DNLocationManager()

class DNLocationManager: NSObject, CLLocationManagerDelegate {
    // 创建一个单例
    open class var shared: DNLocationManager {
        return locationManagerShareInstance
    }
    
    // 定义闭包变量
    private var onUserCLLocation: userCLLocation?
    private var onCityString: cityString?
    private var onCLLocationError: CLLocationError?
    private var onCityError: cityError?
    
    // MARK: 获取城市名称
    open func getCity(city: @escaping cityString, error: @escaping cityError) {
        startLocation()
        onCityString = city
        onCityError = error
    }
    
    // MARK: 获取坐标
    open func getUserCLLocation(cllocation: @escaping userCLLocation, error: @escaping CLLocationError) {
        startLocation()
        onUserCLLocation = cllocation
        onCLLocationError = error
    }
    
    // MARK: 获取城市名称和坐标
    open func getUserCLLocationAndCity(cllocation: @escaping userCLLocation, city: @escaping cityString, cllocationError: @escaping CLLocationError, cityError: @escaping cityError) {
        startLocation()
        onUserCLLocation = cllocation
        onCityString = city
        onCLLocationError = cllocationError
        onCityError = cityError
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
    private func startLocation() {
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
                } else {// 城市信息获取失败
                    if self.onCityError != nil {
                        self.onCityError!(error)
                    }
                }
            }
        }
        // 不需要定位的时候停止定位
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败: %@", error)
        if onCLLocationError != nil {
            onCLLocationError!(error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("用户未决定")
        case .restricted: // 暂时没啥用
            print("访问受限")
        case .denied: // /定位关闭时和对此APP授权为never时调用
            if CLLocationManager.locationServicesEnabled() {
                print("定位开启,但被拒绝")
                if let settingUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingUrl) && Double(UIDevice.current.systemVersion)! >= 8.0 {
                        //iOS8可直接跳转到设置界面
                        let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，是否前往设置开启", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        })
                        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                            UIApplication.shared.openURL(settingUrl)
                        })
                        alertVC.addAction(cancelAction)
                        alertVC.addAction(okAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                    }
                } else {
                    let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，请在设置中开启", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                    })
                    alertVC.addAction(cancelAction)
                    let vc = UIApplication.shared.keyWindow?.rootViewController
                    vc?.present(alertVC, animated: true, completion: nil)
                }
                
            } else {
                print("定位关闭,不可用")
                if let settingUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingUrl) && Double(UIDevice.current.systemVersion)! >= 8.0 {
                        //iOS8可直接跳转到设置界面
                        let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，是否前往设置开启", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        })
                        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                            UIApplication.shared.openURL(settingUrl)
                        })
                        alertVC.addAction(cancelAction)
                        alertVC.addAction(okAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                        
                    } else {
                        let alertVC = UIAlertController(title: "提示", message: "定位服务未开启\n打开方式:设置->隐私->定位服务", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                        })
                        alertVC.addAction(cancelAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                    }

                }
            }
            
        case .authorizedAlways:
            print("获取前后台定位授权")
        case .authorizedWhenInUse:
            print("获取前台定位授权")
        }
    }
}
    
