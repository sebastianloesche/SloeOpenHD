//
// Created by consti10 on 02.05.22.
//

#ifndef OPENHD_OPENHD_INTERFACE_H
#define OPENHD_OPENHD_INTERFACE_H

#include <memory>
#include <utility>

#include "USBTetherListener.h"
#include "WBStreams.h"
#include "WifiHotspot.h"
#include "openhd-profile.hpp"
#include "openhd-platform.hpp"
#include "openhd-led-error-codes.h"

class OHDInterface {
 public:
  /**
   * Takes care of everything networking related, like wifibroadcast, usb / tethering / WiFi-hotspot usw.
   */
  explicit OHDInterface(OHDPlatform platform1,OHDProfile profile1);
  // register callback that is called in regular intervals with link statistics
  void set_stats_callback(openhd::link_statistics::STATS_CALLBACK stats_callback) const;
  std::unique_ptr<WBStreams> wbStreams;
  std::unique_ptr<USBTetherListener> usbTetherListener;
  // Verbose string about the current state.
  [[nodiscard]] std::string createDebug() const;
  /**
   * after calling this method with a external device's ip address
   * (for example an externally connected tablet) data will be forwarded to the device's ip address.
   * It is safe to call this method multiple times with the same IP address, since we internally keep track here.
   */
  void addExternalDeviceIpForwarding(std::string ip) const;
  /**
   * stop forwarding data to the device's ip address.
   * Does nothing if the device's ip address is not registered for forwarding or already has ben removed.
   */
  void removeExternalDeviceIpForwarding(std::string ip) const;
 private:
  const OHDProfile profile;
  const OHDPlatform platform;
  std::unique_ptr<WifiHotspot> _wifi_hotspot;
  std::unique_ptr<openhd::rpi::LEDBlinker> _error_blinker;
};

#endif //OPENHD_OPENHD_INTERFACE_H