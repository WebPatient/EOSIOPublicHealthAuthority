all:
	flutter build apk; cp build/app/outputs/apk/release/app-release.apk /usr/local/var/www/WebPatientAppStore/EOSIO-ExposureNotifications.apk
	flutter build ios --no-codesign
install_android:
	adb install -r build/app/outputs/apk/release/app-release.apk

#install_ios:
#	adb install -r build/app/outputs/apk/release/app-release.apk
