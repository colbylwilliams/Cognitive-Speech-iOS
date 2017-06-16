# Cognitive-Speech-iOS

An iOS app written in Swift 4 that demonstrates Microsoft Cognitive Services [Speaker Recognition API][6] 


## Requirements

- Xcode 9.0+ (beta)
- iPhone running iOS 11+ (beta)
- Azure subscription (create a free subscription [here][1])
- [Cognitive Service Azure Resource][0]


## Build

- Open the project in Xcode
- Add your Cognitive Service's key as the value for [`SpeakerIdHeader.subscriptionValue`][3]
- Build and Run on **Device** running iOS 11+


## About

Created by [Colby Williams][5]. 


## License

Licensed under the MIT License (MIT).  See [LICENSE][4] for details.



[0]:https://portal.azure.com/#create/Microsoft.CognitiveServices/apitype/SpeakerRecognition/pricingtier/S0
[1]:https://azure.microsoft.com/free/
[2]:https://github.com/colbylwilliams/Cognitive-Speech-iOS/CognitiveSpeech/CognitiveSpeech/Client/SpeakerIdHeader.swift
[3]:https://github.com/colbylwilliams/Cognitive-Speech-iOS/CognitiveSpeech/CognitiveSpeech/Client/SpeakerIdHeader.swift#L16
[4]:https://github.com/colbylwilliams/Cognitive-Speech-iOS/blob/master/LICENSE
[5]:https://github.com/colbylwilliams
[6]:https://azure.microsoft.com/en-us/services/cognitive-services/speaker-recognition/