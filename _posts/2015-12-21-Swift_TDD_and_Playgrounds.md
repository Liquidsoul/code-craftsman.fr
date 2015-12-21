---
layout: post
title: Swift, TDD and Playgrounds
---

Lately, I have been doing some TDD in Swift.

While following the `red, green, refactor` cycle using the default Xcode test target, I found that deploying on the simulator could easily take several seconds.
So, I asked myself if there was not a faster way of doing this in Swift.

And the answer came quite easily. What do we use when we want to test something quickly in Swift?

That's right, _Playgrounds_!

So I have looked into how I could do TDD using a Playground with the following objective in mind:

`The final code must be easily moved into a classic Xcode project.`

## XCTest in Playgrounds

When we do unit tests in Xcode, we use the `XCTest` framework.
It gives us the `XCTestCase` class to run our tests and `XCTAssert` methods to check the results.
The class is not necessary in our case because we can call the functions direclty to run the tests. But, the methods are.

Yet, when you try to import `XCTest` in your iOS playground you will have this:

`error: cannot load underlying module for 'XCTest'`

In order to use `XCTest` directly, you have to use an OSX playground.

![OSX Playground](/public/images/XCTestPlayground/OSX_Playground.png)

Once done, using a method like `XCTFail` will show you when there is a problem.

![XCTFail error](/public/images/XCTestPlayground/XCTest_exception.png)

But, as you can see, the error is shown on the line of the top-most caller, not on the line where the error actually is. This can prove finding a failing test cumbersome.

## The XCTestPlayground workaround

To address these issues, I had the idea to implement my own `XCT` methods using a nice feature of Playgrounds: `the display of the return value`

Here is the result:

![XCTestPlayground_example](/public/images/XCTestPlayground/XCTestPlayground.png)

With that, you can write test code in a Playground and have direct feedback on which assert passes and which does not.

You can find my implementation of the asserts in [this repository](https://github.com/Liquidsoul/XCTestPlayground). If you want to use this, just add the `XCTestPlayground.swift` file to your Playground's sources folder.

Note that I did not implement all the functions. For example, the `WithAccuracy` ones are missing.
