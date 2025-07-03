import Flutter
import UIKit
import MiniPlengi

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var eventSink: FlutterEventSink?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      DispatchQueue.main.async {
          Plengi.requestAlwaysLocationAuthorization()
      }
      
      let controller = window?.rootViewController as! FlutterViewController
      let eventChannel = FlutterEventChannel(name: "plengi.ai/toFlutter", binaryMessenger: controller.binaryMessenger)
      let methodChannel = FlutterMethodChannel(name: "plengi.ai/fromFlutter", binaryMessenger: controller.binaryMessenger)
      methodChannel.setMethodCallHandler { call, result in
          if call.method == "searchPlace" {
              let refreshResult = Plengi.manual_refreshPlace_foreground()
              result("Plengi 호출 완료: \(refreshResult)")
          } else {
              result(FlutterMethodNotImplemented)
          }
      }
      eventChannel.setStreamHandler(self)
    GeneratedPluginRegistrant.register(with: self)
      _ = Plengi.initialize(clientID: "loplat", clientSecret: "loplatsecret")
      _ = Plengi.setEchoCode(echoCode: "pgj0320")
      _ = Plengi.setDelegate(self)
      _ = Plengi.start()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

extension AppDelegate: PlaceDelegate {
    func responsePlaceEvent(_ plengiResponse: PlengiResponse) {
        let plengiResponse = plengiResponse
        plengiResponse.complex = .init([
            "id": 4,
            "name": "서울고속터미널(경부/영동선)"
        ])
        var mockupPlaces = generateMockupPlaceHistory()
        mockupPlaces.insert(plengiResponse, at: 0)
        
        mockupPlaces.forEach { response in
            let dict = response.toDictionary()
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                eventSink?(jsonString)
            }
        }
    }
    
    private func generateMockupPlaceHistory() -> [PlengiResponse] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") //
        
        // ===response1===
        let response1 = PlengiResponse()
        response1.echoCode = "pgj0320"
        response1.result = .SUCCESS
        response1.type = .PLACE_EVENT
        response1.placeEvent = .ENTER

        let place1 = Place()
        place1.loplat_id = 1640260
        place1.lat = 37.499182
        place1.lng = 127.028928
        place1.name = "로플랫"
        place1.address = "서울 강남구 역삼동 819-6"
        place1.post = "6134"

        let district1 = District()
        district1.lv1_name = "서울"
        district1.lv2_name = "강남구"
        district1.lv3_name = "역삼1동"

        let location1 = Location()
        location1.floor = 9
        location1.lat = 37.499182
        location1.lng = 127.028928
        location1.time = Int64(formatter.date(from: "2025-06-17 9:27:19")!.timeIntervalSince1970 * 1000)

        response1.district = district1
        response1.location = location1
        response1.place = place1
        //====//

        // ===response2===
        let response2 = PlengiResponse()
        response2.echoCode = "pgj0320"
        response2.result = .SUCCESS
        response2.type = .PLACE_EVENT
        response2.placeEvent = .ENTER

        let place2 = Place()
        place2.loplat_id = 1330839
        place2.lat = 37.499957
        place2.lng = 127.026651
        place2.name = "무인양품"
        place2.address = "서울 서초구 서초동 1306-6"
        place2.post = "6614"

        let district2 = District()
        district2.lv1_name = "서울"
        district2.lv2_name = "강남구"
        district2.lv3_name = "역삼1동"

        let location2 = Location()
        location2.floor = 1
        location2.lat = 37.499957
        location2.lng = 127.026651
        location2.time = Int64(formatter.date(from: "2025-06-17 9:00:53")!.timeIntervalSince1970 * 1000)

        response2.district = district2
        response2.location = location2
        response2.place = place2
        //====//

        // ===response3===
        let response3 = PlengiResponse()
        response3.echoCode = "pgj0320"
        response3.result = .SUCCESS
        response3.type = .PLACE_EVENT
        response3.placeEvent = .ENTER

        let place3 = Place()
        place3.loplat_id = 1418626
        place3.lat = 37.501432
        place3.lng = 127.026059
        place3.name = "스마텔 고객플라자"
        place3.address = "서울 강남구 역삼동 814-6"
        place3.post = "6123"

        let district3 = District()
        district3.lv1_name = "서울"
        district3.lv2_name = "강남구"
        district3.lv3_name = "역삼1동"

        let location3 = Location()
        location3.floor = 0
        location3.lat = 37.501432
        location3.lng = 127.026059
        location3.time = Int64(formatter.date(from: "2025-06-17 8:55:32")!.timeIntervalSince1970 * 1000)

        response3.district = district3
        response3.location = location3
        response3.place = place3
        //====//

        // ===response4===
        let response4 = PlengiResponse()
        response4.echoCode = "pgj0320"
        response4.result = .SUCCESS
        response4.type = .PLACE_EVENT
        response4.placeEvent = .ENTER

        let place4 = Place()
        place4.loplat_id = 271470
        place4.lat = 37.503428
        place4.lng = 127.021001
        place4.name = "푸드카페김밥천국"
        place4.address = "서울 서초구 반포동 745-6"
        place4.post = "6543"

        let district4 = District()
        district4.lv1_name = "서울"
        district4.lv2_name = "서초구"
        district4.lv3_name = "반포1동"

        let location4 = Location()
        location4.floor = 1
        location4.lat = 37.503428
        location4.lng = 127.021001
        location4.time = Int64(formatter.date(from: "2025-06-17 8:52:32")!.timeIntervalSince1970 * 1000)

        response4.district = district4
        response4.location = location4
        response4.place = place4
        //====//

        // ===response5===
        let response5 = PlengiResponse()
        response5.echoCode = "pgj0320"
        response5.result = .SUCCESS
        response5.type = .PLACE_EVENT
        response5.placeEvent = .ENTER

        let place5 = Place()
        place5.loplat_id = 1287658
        place5.lat = 37.275571
        place5.lng = 127.143831
        place5.name = "힐링스크린골프존"
        place5.address = "경기 용인시 기흥구 상하동 483-1"
        place5.post = "16986"

        let district5 = District()
        district5.lv1_name = "경기"
        district5.lv2_name = "용인시 기흥구"
        district5.lv3_name = "상하동"

        let location5 = Location()
        location5.floor = -2
        location5.lat = 37.275571
        location5.lng = 127.143831
        location5.time = Int64(formatter.date(from: "2025-06-17 7:53:43")!.timeIntervalSince1970 * 1000)

        response5.district = district5
        response5.location = location5
        response5.place = place5
        //====//

        // ===response6===
        let response6 = PlengiResponse()
        response6.echoCode = "pgj0320"
        response6.result = .SUCCESS
        response6.type = .PLACE_EVENT
        response6.placeEvent = .ENTER

        let place6 = Place()
        place6.loplat_id = 1305843
        place6.lat = 37.276549
        place6.lng = 127.144072
        place6.name = "어정메디칼약국"
        place6.address = "경기 용인시 기흥구 중동 627-5"
        place6.post = "16988"

        let district6 = District()
        district6.lv1_name = "경기"
        district6.lv2_name = "용인시 기흥구"
        district6.lv3_name = "동백3동"

        let location6 = Location()
        location6.floor = 0
        location6.lat = 37.276549
        location6.lng = 127.144072
        location6.time = Int64(formatter.date(from: "2025-06-17 7:51:05")!.timeIntervalSince1970 * 1000)

        response6.district = district6
        response6.location = location6
        response6.place = place6
        //====//

        // ===response7===
        let response7 = PlengiResponse()
        response7.echoCode = "pgj0320"
        response7.result = .SUCCESS
        response7.type = .PLACE_EVENT
        response7.placeEvent = .ENTER

        let place7 = Place()
        place7.loplat_id = 1256395
        place7.lat = 37.276534
        place7.lng = 127.144254
        place7.name = "중동서울정형외과의원"
        place7.address = "경기 용인시 기흥구 중동 627-5"
        place7.post = "16988"

        let district7 = District()
        district7.lv1_name = "경기"
        district7.lv2_name = "용인시 기흥구"
        district7.lv3_name = "동백3동"

        let location7 = Location()
        location7.floor = 0
        location7.lat = 37.276534
        location7.lng = 127.144254
        location7.time = Int64(formatter.date(from: "2025-06-16 19:28:32")!.timeIntervalSince1970 * 1000)

        response7.district = district7
        response7.location = location7
        response7.place = place7
        //====//

        // ===response8===
        let response8 = PlengiResponse()
        response8.echoCode = "pgj0320"
        response8.result = .SUCCESS
        response8.type = .PLACE_EVENT
        response8.placeEvent = .ENTER

        let place8 = Place()
        place8.loplat_id = 1083022
        place8.lat = 37.27571
        place8.lng = 127.144361
        place8.name = "GS25"
        place8.address = "경기 용인시 기흥구 상하동 489"
        place8.post = "16986"

        let district8 = District()
        district8.lv1_name = "경기"
        district8.lv2_name = "용인시 기흥구"
        district8.lv3_name = "상하동"

        let location8 = Location()
        location8.floor = 0
        location8.lat = 37.27571
        location8.lng = 127.144361
        location8.time = Int64(formatter.date(from: "2025-06-16 19:26:10")!.timeIntervalSince1970 * 1000)

        response8.district = district8
        response8.location = location8
        response8.place = place8
        //====//

        // ===response9===
        let response9 = PlengiResponse()
        response9.echoCode = "pgj0320"
        response9.result = .SUCCESS
        response9.type = .PLACE_EVENT
        response9.placeEvent = .ENTER

        let place9 = Place()
        place9.loplat_id = 1517181
        place9.lat = 37.271793
        place9.lng = 127.108705
        place9.name = "MJ통신"
        place9.address = "경기 용인시 기흥구 신갈동 68-6"
        place9.post = "17064"

        let district9 = District()
        district9.lv1_name = "경기"
        district9.lv2_name = "용인시 기흥구"
        district9.lv3_name = "신갈동"

        let location9 = Location()
        location9.floor = 0
        location9.lat = 37.271793
        location9.lng = 127.108705
        location9.time = Int64(formatter.date(from: "2025-06-16 19:11:51")!.timeIntervalSince1970 * 1000)

        response9.district = district9
        response9.location = location9
        response9.place = place9
        //====//

        // ===response10===
        let response10 = PlengiResponse()
        response10.echoCode = "pgj0320"
        response10.result = .SUCCESS
        response10.type = .PLACE_EVENT
        response10.placeEvent = .ENTER

        let place10 = Place()
        place10.loplat_id = 1498840
        place10.lat = 37.500737
        place10.lng = 127.026363
        place10.name = "포도여성의원"
        place10.address = "서울 강남구 역삼동 815-4"
        place10.post = "6129"

        let district10 = District()
        district10.lv1_name = "서울"
        district10.lv2_name = "강남구"
        district10.lv3_name = "역삼1동"

        let location10 = Location()
        location10.floor = 0
        location10.lat = 37.500737
        location10.lng = 127.026363
        location10.time = Int64(formatter.date(from: "2025-06-16 18:24:56")!.timeIntervalSince1970 * 1000)

        response10.district = district10
        response10.location = location10
        response10.place = place10
        //====//

        // ===response11===
        let response11 = PlengiResponse()
        response11.echoCode = "pgj0320"
        response11.result = .SUCCESS
        response11.type = .PLACE_EVENT
        response11.placeEvent = .ENTER

        let place11 = Place()
        place11.loplat_id = 383158
        place11.lat = 37.498529
        place11.lng = 127.027777
        place11.name = "강남역 지하쇼핑센터/가인"
        place11.address = "서울 강남구 역삼동 804"
        place11.post = "6134"

        let district11 = District()
        district11.lv1_name = "서울"
        district11.lv2_name = "강남구"
        district11.lv3_name = "역삼1동"

        let location11 = Location()
        location11.floor = -1
        location11.lat = 37.498529
        location11.lng = 127.027777
        location11.time = Int64(formatter.date(from: "2025-06-16 18:20:41")!.timeIntervalSince1970 * 1000)

        response11.district = district11
        response11.location = location11
        response11.place = place11
        //====//


        
        return [
            response1,
            response2,
            response3,
            response4,
            response5,
            response6,
            response7,
            response8,
            response9,
            response10,
            response11,
        ]
    }
    
}

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events

    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
    
    // 네이티브에서 호출할 함수
    func sendMessageToFlutter(message: String) {
        eventSink?(message)
    }
}

extension PlengiResponse {
    func toDictionary() -> [String: Any] {
        return [
            "echoCode": echoCode as Any,
            "errorReason": errorReason as Any,
            "result": result.rawValue,
            "type": type.rawValue,
            "placeEvent": placeEvent.rawValue,
            "place": place?.toDictionary() as Any,
            "area": area?.toDictionary() as Any,
            "complex": complex?.toDictionary() as Any,
            "geofence": geofence?.toDictionary() as Any,
            "nearbys": nearbys?.map { $0.toDictionary() } as Any,
            "district": district?.toDictionary() as Any,
            "advertisement": advertisement?.toDictionary() as Any,
            "location": location?.toDictionary() as Any
        ]
    }
}

extension Place {
    func toDictionary() -> [String: Any] {
        return [
            "loplat_id": loplat_id,
            "name": name,
            "tags": tags,
            "distance": distance,
            "floor": floor,
            "lat": lat,
            "lng": lng,
            "accuracy": accuracy,
            "threshold": threshold,
            "client_code": client_code,
            "category": category,
            "category_code": category_code,
            "address": address,
            "address_road": address_road,
            "post": post,
            "pnu": pnu
        ]
    }
}

extension Area {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "tag": tag,
            "lat": lat,
            "lng": lng
        ]
    }
}

extension Complex {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "branch_name": branch_name,
            "category": category,
            "category_code": category_code
        ]
    }
}

extension Fence {
    func toDictionary() -> [String: Any] {
        return [
            "gfid": gfid,
            "dist": dist,
            "name": name,
            "client_code": client_code
        ]
    }
}

extension Geofence {
    func toDictionary() -> [String: Any] {
        return [
            "lat": lat,
            "lng": lng,
            "fences": fences.map { $0.toDictionary() }
        ]
    }
}

extension Nearbys {
    func toDictionary() -> [String: Any] {
        return [
            "loplat_id": loplat_id,
            "placename": placename,
            "tags": tags,
            "floor": floor,
            "lat": lat,
            "lng": lng,
            "accuracy": accuracy
        ]
    }
}

extension District {
    func toDictionary() -> [String: Any] {
        return [
            "lv0_code": lv0_code,
            "lv1_name": lv1_name,
            "lv2_name": lv2_name,
            "lv3_name": lv3_name,
            "lv1_code": lv1_code,
            "lv2_code": lv2_code,
            "lv3_code": lv3_code
        ]
    }
}

extension Advertisement {
    func toDictionary() -> [String: Any] {
        return [
            "alarm": alarm,
            "title": title as Any,
            "body": body as Any,
            "img": img,
            "campaign_id": campaign_id,
            "delay": delay,
            "delay_type": delay_type,
            "intent": intent,
            "msg_id": msg_id,
            "target_pkg": target_pkg,
            "client_code": client_code,
            "fcm_token_id": fcm_token_id,
            "ad_type": ad_type
        ]
    }
}

extension Location {
    func toDictionary() -> [String: Any] {
        return [
            "provider": provider,
            "floor": floor,
            "time": time,
            "lat": lat,
            "lng": lng,
            "accuracy": accuracy
        ]
    }
}
