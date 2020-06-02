# EOSIO Public Health Authority

My implementation of EOSIO smart contracts to apply blockchain technology to address the problems and/or expected societal changes related to the COVID-19 pandemic thru Exposure Notifications API.

This repository is a project submitted to EOSIO Virtual Hackathon: Coding for Change

Youtube demo #1: https://www.youtube.com/watch?v=ZSu6OHwAAXY (8:43 mins)
<br>Youtube demo #2: https://youtu.be/eghtSy9Zt8c (3:17 mins)
<br>Youtube demo #3: https://youtu.be/jknyGfeAMXs (1:44 mins)


# How to quick start using the app

- Step 1<br>
Clone repository or download ZIP file

- Step 2<br>
Open a terminal at eosio_exposure_notifications directory

- Step 3<br>
At the opened terminal type: flutter run<br>
Then press enter

- Step 4<br>
Turn on the bluetooth on your mobile device

- Step 5<br>
Wait for EOSIO Public Health Authority App<br>
Then press on 'TURN ON EXPOSURE NOTIFICATIONS'

- Step 6<br>
If you think you have been exposed to COVID‑19 and develop a fever and symptoms, such as cough or difficulty breathing, call your healthcare provider for medical advice.
When infected with COVID-19 press on 'NOTIFY OTHERS'

- Step 7<br>
An authorized healthcare provider with valid Owner and Active Private keys will complete the next screen and press 'submit'<br>

- Step 8<br>
You will be notified if you have been exposed to someone who reported a positive COVID-19 result.<br>


# Inspiration for EOSIO Public Health Authority App

This software is inspired by the need of a solution for decentralized contact tracing by merging blockchain technology and Bluetooth technology on Android and iOS mobile devices.

# What EOSIO Public Health Authority App does

Using Bluetooth technology this app generates and broadcast UUIDs so other users can scan and save such UUIDs. 

At the moment of infection the app notify and report the infected UUIDs to the EOSIO blockchain. 

User gets alerts when the app algorithm matches a scanned UUID with a reported UUID.

# How I built EOSIO Public Health Authority App

Built with Flutter Mobile UI Framework for Android and iOS.

# What I learned

 - Learned how to create an Android/iOS flutter plugin: https://github.com/WebPatient/EOSIOPublicHealthAuthority/tree/master/flutter_exposure_notifications
 - Learned how to create and push transactions to EOSIO blockchain programmatically using dart programing language.

# What's next for Covid19 Contact Tracing

 - Implement iOS UUIDs scanning native code
 - QR code scanning implementation 


 
