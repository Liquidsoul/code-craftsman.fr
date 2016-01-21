---
layout: post
title: NSDateFormatter performance
---

As many of you may know, `NSDateFormatter`'s initializer has quite an overhead.
In this post, I want to illustrate this with a simple performance unit test and then show how I tried to limit this issue in Swift.

## Testing your code's performance

When you create your project in Xcode and include Unit tests, you may have seen that the test file template contains this method:

{% highlight swift %}
func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
        // Put the code you want to measure the time of here.
    }
}
{% endhighlight %}

And I think that most of us just delete it and never use it again because who cares about the performance of this tiny piece of code, right?

Honestly, I did not use it in production code so I am not pointing fingers.

But here, we will use this nice feature to compute the performance evolution of a method that compute 10000 times `stringFromDate`.
I use a number this large so we can see the performance gain more easily.

So, let's start with the first naive implementation:

{% highlight swift %}
let iterationsCount = 10000
let date = NSDate()
let customDateFormat = "YYYYMMDD'T'HHmmss"

func testPerformance_NSDateFormatter() {
    self.measureBlock {
        for _ in 1...self.iterationsCount {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = self.customDateFormat
            dateFormatter.stringFromDate(self.date)
        }
    }
}
{% endhighlight %}

Time for this is `0.863s`.

As you can see, we instanciate the date formatter every time. Let's move this outside the loop:

{% highlight swift %}
let dateFormatter = NSDateFormatter()
for _ in 1...self.iterationsCount {
    dateFormatter.dateFormat = self.customDateFormat
    dateFormatter.stringFromDate(self.date)
}
{% endhighlight %}

Time is now `0.124s`, so a `86%` better. Not bad!

So sharing a `NSDateFormatter` instance is a very good thing. But what if the `dateFormat` does not need to be changed every time?

{% highlight swift %}
let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = self.customDateFormat
for _ in 1...self.iterationsCount {
    dateFormatter.stringFromDate(self.date)
}
{% endhighlight %}

Time is now `0.089s`, we gain another `4%`!

So, whenever we can we should share the same `NSDateFormatter` instance with the same `dateFormat` setup.
