# AppConnectSDK Library

The AppConnectSDK is a library designed to facilitate communication between iOS applications using ContentProviders. It allows applications to securely exchange data with each other, providing a seamless integration experience.

## Installation
To use the AppConnectSDK library in your iOS project, follow these steps:

1. Clone the library repository to your local machine:

2. Add package to your xcode project open XCode `File` > `Add Package Dependencies...` > `Add Local...` > select library package dir then add package

3. In your project target `General` > `Frameworks, Libraries, and Embedded Content` > `+` Choose library to add.

## Usage

Here's how you can use the AppConnectSDK library to communicate between two applications:

### Add App group to your 

- Go to your target and `Signing & Capailities` select Team
- Add an App Group Capabilities
  - Select your main app target from the list of targets.
  - Go to the `Signing & Capabilities` tab.
  - Click the `+ Capability` button.
  - Search for `App Groups` and click on it to add it to your project.
- Enable App Groups
  - With the App Groups capability added, expand it by clicking the disclosure arrow.
  - Turn on the switch next to `App Groups`.
  - Xcode will prompt you to create a new app group or choose an existing one. Click the `+` button to create a new one.
- Create an App Group Identifier
  - A dialog will appear asking you to provide a name for your App Group. Enter a unique identifier for your app group, for example, `group.com.yourcompany.yourappgroup`.
  - Click `OK` to create the app group.

### Example: Application A sending data to Application B

```swift
import AppConnectSDKSwift

...

let appGroup = "group.com.yourcompany.yourappgroup"
let source = "appA"
let destination = "appB"
let a2bChannel = AppConnectSDK.createChannel(
    appGroup: appGroup,
    source: source,
    destination: destination,
    config: ChannelConfiguration(
        commitOnRead: false
    )
)

let expiryDate = Int(Date().timeIntervalSince1970 * 1000)
a2bChannel.send(message: "Hello AppA", expiry: expiryDate + (1000 * 60 * 30))
```

### Example: Application B sending data to Application A

```swift
import AppConnectSDKSwift

...

let appGroup = "group.com.yourcompany.yourappgroup"
let source = "appB"
let destination = "appA"
let b2aChannel = AppConnectSDK.createChannel(
    appGroup: appGroup,
    source: source,
    destination: destination,
    config: ChannelConfiguration(
        commitOnRead: false
    )
)

do {
    let message = try b2aChannel.read()
    print("message: ", message)
    b2aChannel.commit()
} catch {
    print("error: ", error)
}
```