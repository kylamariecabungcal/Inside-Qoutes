/// App Configuration
///
/// Set [useLocalhost] to true/false to switch between browser testing and phone testing
class AppConfig {
  // Set this to true when testing in browser (Edge, Chrome, etc.)
  // Set this to false when testing on physical device
  static const bool useLocalhost = false;

  // Get the appropriate base URL based on the configuration
  static String getBaseUrl() {
    if (useLocalhost) {
      // For testing in browser on the same machine
      return 'http://localhost:3000/api';
    } else {
      // For testing on physical device (use your computer's IP)
      return 'http://10.0.2.165:3000/api';
    }
  }

  // For reference - other URLs you might need:
  // For Android Emulator: 'http://10.0.2.2:3000/api'
  // For iOS Simulator: 'http://localhost:3000/api'
  // For physical device on same WiFi: 'http://<YOUR_COMPUTER_IP>:3000/api'
}
