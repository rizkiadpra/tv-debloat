package com.rizkiadpra.rcpair;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.os.Bundle;
import android.util.Log;

/**
 * Starts Bluetooth bonding with one device by MAC address, then closes.
 *
 *   adb shell am start -n com.rizkiadpra.rcpair/.PairActivity --es mac AA:BB:CC:DD:EE:FF
 *
 * Why it exists: Xiaomi's BleRemoteService only bonds a remote that is "close enough"
 * (txPower - rssi <= 51) or already saved, and the adb shell user lacks BLUETOOTH_ADMIN,
 * so it cannot call createBond itself. An ordinary app holding BLUETOOTH_ADMIN can.
 * After the bond forms, BleRemoteService takes over the remote as usual.
 * Progress goes to logcat under the tag "RcPair".
 */
public class PairActivity extends Activity {
    private static final String TAG = "RcPair";
    private static final int TRANSPORT_LE = 2; // BluetoothDevice.TRANSPORT_LE, hidden on API 28

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        String mac = getIntent().getStringExtra("mac");
        try {
            pair(mac == null ? "" : mac.trim().toUpperCase());
        } catch (RuntimeException e) {
            Log.e(TAG, "pairing request failed", e);
        }
        finish();
    }

    private void pair(String mac) {
        BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
        if (adapter == null || !adapter.isEnabled()) {
            Log.e(TAG, "Bluetooth is off or missing");
            return;
        }
        if (!BluetoothAdapter.checkBluetoothAddress(mac)) {
            Log.e(TAG, "not a valid MAC address: '" + mac + "'");
            return;
        }
        BluetoothDevice d = adapter.getRemoteDevice(mac);
        Log.i(TAG, "device " + mac + " name=" + d.getName() + " type=" + d.getType()
                + " bondState=" + d.getBondState());
        if (d.getBondState() != BluetoothDevice.BOND_NONE) {
            Log.i(TAG, "already bonding or bonded, nothing to do");
            return;
        }
        if (adapter.isDiscovering()) adapter.cancelDiscovery();

        // The remote is Bluetooth LE. Ask for LE transport explicitly; plain createBond() picks the
        // transport from the cached device type and could try classic Bluetooth instead.
        try {
            Object ok = BluetoothDevice.class.getMethod("createBond", int.class).invoke(d, TRANSPORT_LE);
            Log.i(TAG, "createBond(TRANSPORT_LE) returned " + ok);
        } catch (ReflectiveOperationException e) {
            Log.w(TAG, "createBond(int) unavailable (" + e + "), using createBond()");
            Log.i(TAG, "createBond() returned " + d.createBond());
        }
    }
}
