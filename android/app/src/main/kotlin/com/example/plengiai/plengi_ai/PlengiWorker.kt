//package com.example.plengiai.plengi_ai
//
//import android.content.Context
//import androidx.work.CoroutineWorker
//import androidx.work.WorkerParameters
//import com.loplat.placeengine.Plengi
//import com.loplat.placeengine.PlengiResponse
//import com.loplat.placeengine.OnPlengiListener
//import kotlinx.coroutines.Dispatchers
//import kotlinx.coroutines.withContext
//
//// 안 씀 나중에 필요하면 참고해서 사용
//
//class PlengiWorker(
//    private val context: Context,
//    params: WorkerParameters
//) : CoroutineWorker(context, params) {
//
//    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
//        try {
//            Plengi.getInstance(context).TEST_refreshPlace_foreground(object : OnPlengiListener {
//                override fun onSuccess(response: PlengiResponse?) {
//                    response?.let {
//                        // Flutter로 이벤트 전송
//                        MainApplication.eventSink?.success(it.toString())
//                    }
//                }
//
//                override fun onFail(response: PlengiResponse?) {
//                    response?.let {
//                        MainApplication.eventSink?.success(it.toString())
//                    }
//                }
//            })
//            Result.success()
//        } catch (e: Exception) {
//            Result.failure()
//        }
//    }
//}