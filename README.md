# NET

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
