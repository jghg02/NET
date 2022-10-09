# ``NET``

<img width="60" alt="iOS" src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white"> <img width="70" alt="iOS" src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white">

This library provee all the necessary logic to make a request to any API from your application. This is an implementation usinf ``async`` and ``await``

##  Installation

Add JNetwork Client as a dependency through Xcode or directly to Package.swift:

```
.package(url: "https://github.com/jghg02/NET", branch: "main")
```


## Usage

```swift
    let client = NETClient<[Recipes], RegistrationError>()
    let request = NETRequest(url: URL(string: "https://example.com")!)
    switch await client.request(request) {
    case .success(let data):
        print(data)
    case .failure(let error):
        print("Error")
        print(error.localizedDescription)
    }
```
