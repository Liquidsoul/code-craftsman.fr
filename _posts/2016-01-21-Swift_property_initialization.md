---
layout: post
title: Swift property initialization
---

Let's say we want to share a `NSDateFromatter` instance in the scope of a class, for example, a `UITableViewDataSource`. We would declare it like this:

```swift
class MyTableViewController: NSObject, UITableViewDataSource {
    let dateFormatter: NSDateFormatter

    override init() {
        self.dateFormatter = NSDateFormatter()
        super.init()
    }

    // protocol implementation skipped, not relevant in this example
}
```

As you can see, we need to initialize `dateFormatter` in `init()`. And to be sure the formatter is correctly configured, we would need to do it there too:

```swift
    override init() {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateStyle = .NoStyle
        self.dateFormatter.timeStyle = .FullStyle
        super.init()
    }
```

I like to have tiny functions with explicit names.
But, as of today, we cannot factorize all of this in a method of `MyTableViewController` because `self` is not initialized. We need to split instanciation and configuration:

```swift
    override init() {
        self.dateFormatter = NSDateFormatter()
        super.init()
        self.configureDateFormatter()
    }

    func configureDateFormatter() {
        self.dateFormatter.dateStyle = .NoStyle
        self.dateFormatter.timeStyle = .FullStyle
    }
```

And we need to do that for every property... not very practical.
To prevent cluttering up `init()` with all the property initialization values we could do that when we declare `dateFormatter`:

```swift
class MyTableViewController: NSObject, UITableViewDataSource {
    let dateFormatter = NSDateFormatter()

    override init() {
        super.init()
        self.configureDateFormatter()
    }

    func configureDateFormatter() {
        self.dateFormatter.dateStyle = .NoStyle
        self.dateFormatter.timeStyle = .FullStyle
    }

    // protocol implementation skipped, not relevant in this example
}
```

This is better and the property type is now inferred.

But I am not quite satisfied with this.

Isn't there a way to do this in Swift without declaring and calling `configureDateFormatter()`? Which is, by the way, only called once during the lifetime of the object?

**Closures**!

Here is how:

```swift
class MyTableViewController: NSObject, UITableViewDataSource {
    let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .FullStyle
        return dateFormatter
    }()

    // protocol implementation skipped, not relevant in this example
}
```

As you can see, we do not need to override `init()` anymore! And we have all `dataFormatter` initialization and configuration in one place.

Hope that someone will find this useful!
