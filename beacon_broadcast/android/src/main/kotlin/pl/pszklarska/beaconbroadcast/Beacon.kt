package pl.pszklarska.beaconbroadcast

import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import org.altbeacon.beacon.Beacon
import org.altbeacon.beacon.BeaconManager
import org.altbeacon.beacon.BeaconParser
import org.altbeacon.beacon.BeaconTransmitter
import org.altbeacon.beacon.BeaconTransmitter.checkTransmissionSupported
import org.altbeacon.beacon.Region
import java.util.*
import io.flutter.Log

const val RADIUS_NETWORK_MANUFACTURER = 0x0118

class Beacon {

  private lateinit var context: Context
  private var beaconTransmitter: BeaconTransmitter? = null
  private var advertiseCallback: ((Boolean) -> Unit)? = null

  fun init(context: Context) {
    this.context = context
  }

  fun start(beaconData: BeaconData, advertiseCallback: ((Boolean) -> Unit)) {
    this.advertiseCallback = advertiseCallback

    if (isTransmissionSupported() == 0) {
      val beaconParser = BeaconParser().setBeaconLayout(beaconData.layout ?: BeaconParser.ALTBEACON_LAYOUT)
      beaconTransmitter = BeaconTransmitter(context, beaconParser)
    }

    val beacon = Beacon.Builder()
        .setId1(beaconData.uuid)
        .setId2(beaconData.majorId.toString())
        .setId3(beaconData.minorId.toString())
        .setTxPower(beaconData.transmissionPower ?: -59)
        .setDataFields(Arrays.asList(0L))
        .setManufacturer(beaconData.manufacturerId ?: RADIUS_NETWORK_MANUFACTURER)
        .build()


    beaconTransmitter?.startAdvertising(beacon, object : AdvertiseCallback() {
      override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
        super.onStartSuccess(settingsInEffect)
        advertiseCallback(true)
      }

      override fun onStartFailure(errorCode: Int) {
        super.onStartFailure(errorCode)
        advertiseCallback(false)
      }
    })
  }

  fun isAdvertising(): Boolean {
    return beaconTransmitter?.isStarted ?: false
  }

  fun isTransmissionSupported(): Int {
    return checkTransmissionSupported(context)
  }

  fun scan(): String {
    val region = Region("backgroundRegion", null, null, null)

    val beaconManager: BeaconManager = BeaconManager.getInstanceForApplication(context)
    beaconManager.getBeaconParsers().add(BeaconParser().setBeaconLayout(BeaconParser.ALTBEACON_LAYOUT))
    beaconManager.startRangingBeaconsInRegion(region)
    return "Scan results:"
  }

  @Override
  fun didRangeBeaconsInRegion(beacons: Collection<Beacon>, region: Region?) {
    for (beacon in beacons) {
      Log.i("DEBUG", "I see an Exposure Notification Service beacon with rolling proximity identifier " + beacon.getId1())
    }
  }

  fun stop() {
    beaconTransmitter?.stopAdvertising()
    advertiseCallback?.invoke(false)
  }

}