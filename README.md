### Basic Swift app updater

Very basic version checker and updater; prompt for download, for SwiftUI 5.5+.

I use this for my apps. I wanted the most straight forward prompt for updated version.

### Usage

1. make an `updater.json`

```
{
    "product": "myapp",
    "version": "2.6",
    "file":    "MyApp2.6.zip"
}
```

2. store it in a base url at e.g. `https://example.com/myapp`

If the file is in a sub-folder, update accordingly e.g. `download/MyApp2.6.zip`

3. add this library to your project via `File > Add Package...` 

4. when desired or at application start, fetch for a new version and alert the user. We use the main thread to display the prompt.

```
Task {
    await BasicUpdater(targetURL: "https://example.com/myapp", backOffDays: 5).checkForUpdate()
}
```

So that we don't ask every time the app starts; we have a `backOffDays` e.g. 5 days until we ask again.

### Notes

We do a simple string comparison between the app version and the remote version, as to avoid the carfuffle of issues related to minor and major version. If it's different, we prompt for update.

Ensure that your app has sandbox authorisation of loading remote content, via "being a network client".
