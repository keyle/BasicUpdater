### Basic updater

Basic version checker and updater + start download for SwiftUI 5.5+

I use this for my apps, pretty straight forward.

1. make an `updater.json`

```
{
    "product": "myapp",
    "version": "2.6",
    "file":    "MyApp2.6.zip"
}
```

2. store it in a base url at e.g. `https://example.com/myapp`

make sure the file is in that folder or a sub-folder (update accordingly) e.g. `download/MyApp2.6.zip`

3. add this library to your project via `File > Add Package...` 

4. when desired, fetch for a new version and alert the user. We use the main thread to display the prompt.

```
Task {
    await BasicUpdater(targetURL: "https://example.com/myapp", backOffDays: 5).checkForUpdate()
}
```

so that we don't ask every time the app starts, we have a `backOffDays` e.g. 5 days until we ask again.
