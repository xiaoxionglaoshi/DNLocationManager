# DNLocationManager
地理位置信息定位功能, 可定位城市和坐标等位置信息

### 使用方法(其他信息调用类似)
```
DNLocationManager.shared.getCity(city: { (city) in
            print(city)
   }) { (error) in
           print("获取城市失败")
 }
```
