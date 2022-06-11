
import PackageDescription
let package = Package(
    name: "QR Code To Sms",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/yannickl/QRCodeReader.swift.git", versions: "10.1.0" ..< Version.max)
    ]
)
