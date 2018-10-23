//
//  MHMapViewController.swift
//  TestMap
//
//  Created by  on 2018/10/2.
//  Copyright © 2018年 com.xiantian. All rights reserved.
//

import UIKit

public  let kScreenWidth = UIScreen.main.bounds.size.width
public  let kScreenHeight = UIScreen.main.bounds.size.height

class MHMapViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {
    var mapView: MAMapView!
    var tableView: UITableView!
    
    var currentLocation: CLLocation!  //当前位置
    var search: AMapSearchAPI!
    var dataArray = NSMutableArray()
    var pointAnnotation:MAPointAnnotation!   //全局标签
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        
        //mapview
        AMapServices.shared().enableHTTPS = true
        mapView = MAMapView(frame:CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight/2))
        mapView.showsCompass = false
        mapView.delegate = self
        mapView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.addSubview(mapView)
        
        //tableview
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: self.mapView.frame.maxY, width: kScreenWidth, height: kScreenHeight/2), style: UITableViewStyle.plain)
        self.tableView.register(UITableViewCell.self , forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        //全局pointAnnotion
        self.pointAnnotation = MAPointAnnotation.init()
        self.mapView.addAnnotation(self.pointAnnotation)
        
        
        //在地图中心放置pointAnnotionView 拖动地图时pointAnnotionView一直处于中心
        let pointCenterImgView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 72))
        pointCenterImgView.image = UIImage.init(named: "greenPin")
        pointCenterImgView.center = CGPoint.init(x: kScreenWidth/2, y: kScreenHeight/4)
        self.view.addSubview(pointCenterImgView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.zoomLevel = 17
        mapView.showsScale = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        if self.search == nil {
            self.search = AMapSearchAPI.init()
            self.search.delegate = self
        }
    }
    
    /// 初始化poi
    func initSearchChs()  {
        if self.currentLocation == nil  {
            return
        }
        
        let request = AMapPOIAroundSearchRequest.init()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(self.currentLocation.coordinate.latitude), longitude: CGFloat(self.currentLocation.coordinate.longitude))
        request.types = "地名地址信息"
        request.sortrule = 0
        request.requireExtension = true
        self.search.aMapPOIAroundSearch(request)
        
     }
    
    /// 点击地图某个点时 返回经纬度 放置annotionView 然后检索poi
    ///
    /// - Parameters:
    ///   - mapView:
    ///   - coordinate:
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        print("点击 latitude= %f, longitude = %f", coordinate.latitude, coordinate.longitude)
        self.pointAnnotation.coordinate = coordinate  //改变annotionView的位置 放置在点击的位置上
        self.currentLocation = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.initSearchChs()
    }
    
    
    /// 更新位置时调用 改变当前的location
    ///
    /// - Parameters:
    ///   - mapView:
    ///   - userLocation:
    ///   - updatingLocation:
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        print("latitude == %f",userLocation.coordinate.latitude)
        print("longitude == %f", userLocation.coordinate.longitude)
        self.currentLocation = CLLocation.init(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        self.initSearchChs() //搜索附近的poi信息
    }
    
    
    /// 点击地图上的AnnotationView
    ///
    /// - Parameters:
    ///   - mapView:
    ///   - view:
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        if view.annotation.isKind(of: MAUserLocation.self) {
            /// 当点击的位置进行检索
            if self.currentLocation != nil {
                let request = AMapReGeocodeSearchRequest.init()
                request.location = AMapGeoPoint.location(withLatitude: CGFloat(self.currentLocation.coordinate.latitude), longitude: CGFloat(self.currentLocation.coordinate.longitude))
                self.search.aMapReGoecodeSearch(request)
            }
        }
    }
    
    /// 点击annotion时弹框 逆编码
    ///
    /// - Parameters:
    ///   - request:
    ///   - response:
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        print("response == %@", response)
        
        var str1 = response.regeocode.addressComponent.city  //addressComponent包含用户当前地址
        if str1?.count == 0 {
            str1 = response.regeocode.addressComponent.province
        }
        self.mapView.userLocation.title = str1
        self.mapView.userLocation.subtitle = response.regeocode.formattedAddress
    }
    
    //回调方法中把poi搜到的地址存到数组中 刷新tableview即可
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.pois.count == 0 {
            return
        }
        self.dataArray.removeAllObjects()
        self.dataArray.addObjects(from: response.pois)
        self.tableView.reloadData()
    }
    
    /// 拖动地图后调用
    ///
    /// - Parameters:
    ///   - mapView:
    ///   - animated:
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        let centerCoordinate = mapView.region.center  //中心点经纬度
        /// 当点击的位置进行检索
        self.currentLocation = CLLocation.init(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        self.initSearchChs() //搜索附近的poi信息
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
}


extension MHMapViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
}

extension MHMapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if self.dataArray.count > indexPath.row {
            let item = self.dataArray[indexPath.row] as! AMapPOI
            cell.textLabel?.text = String(format:"%@",item.address)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


