# QCIM


xcodebuild BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode" -project '_Pods.xcodeproj' -target 'QCIM' -sdk iphonesimulator


xcodebuild BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode" -project '_Pods.xcodeproj' -target 'QCIM' -sdk iphoneos

lipo -create ./Example/build/Release-iphonesimulator/QCIM/QCIM.framework/QCIM  ./Example/build/Release-iphoneos/QCIM/QCIM.framework/QCIM  -output QCIMLib