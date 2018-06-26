# giphySearch

Hey guys,

Please clone the master branch (or download it) and run a pod install in the directory with the Podfile.
Just one pod - FLAnimatedImage.
The project was written in Swift 4.1 and Xcode 9.4 (and Im on Cocoapods 1.5.3)

Any issues, reach me at msadoon@live.com, I'll reply ASAP.

Enjoy! ;)

Known issues:
1. Sometimes individual images dont load/missed when scrolling between images that do load. Suspect image is available in cache but cell not laying out in time to display.
2. Double check searching for term with one result and loading "more", probably disable more button if no more offsets available.
3. Crash occurs when reloading a searching a previously searched term and no images load.
