---
layout: post
title: Testing a Reactive Cocoa App that uses CocoaPods
---

Last weekend, I stumbled across something while trying to learn MVVM.

I was playing with the [Colin Eberhardt's tutorial](http://www.raywenderlich.com/74106/mvvm-tutorial-with-reactivecocoa-part-1) which explains how to set up the pattern using ReactiveCocoa. As I was progressing through the [second part](http://www.raywenderlich.com/74131/mvvm-tutorial-with-reactivecocoa-part-2), I saw this note:
`If you’re feeling adventurous, prove it by writing a unit test that executes a search and navigates from one ViewModel to the next`

Because I wanted to be able to set up more tests by using MVVM, I decided that I felt adventurous enough to test the ViewModels without any UI.

## 'We'll put their name to the test'

So I tried to set up a first basic test:

```objc
- (void)testPerformSearch
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search success"];

    id<RWTViewModelServices> viewModelServices = [[MockService alloc] initWithPushBlock:^(id viewModel) {
        [expectation fulfill];
    }];
    RWTFlickrSearchViewModel *viewModel = [[RWTFlickrSearchViewModel alloc] initWithServices:viewModelServices];

    viewModel.searchText = @"beach";
    [viewModel.executeSearch execute:nil];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}
```

Because I was using some ReactiveCocoa here, it was necessary to import the ReactiveCocoa header to make this work. To do this, I just applied the same pod configuration to my test target:

![Test configuration file](/public/images/RAC_Issue/TestConfigurationFile.png)

Once my test compiled, I was quite confident that it would pass. However, here is what I got:

```objc
error: -[ReactiveCocoaTestIssueTests testExecute] : failed: caught "NSInternalInconsistencyException", "-and must only be used on a signal of RACTuples of NSNumbers. Instead, received: <RACTuple: 0x7fdd8bd40af0> (
    0,
    1
)"
```

This was weird... a `RACTuple` that is not a `RACTuple`...

After some time digging, I found [this isssue](https://github.com/ReactiveCocoa/ReactiveCocoa/issues/901) in ReactiveCocoa github.

One explaination might be that we have more than only one `RACTuple` class.

It appears that this is related to some setup issues with CocoaPods that does not operate well with the default test setup of Xcode.
By default, tests are run against the Host Application (see your Project > Targets > General)

![Testing target image](/public/images/RAC_Issue/TestingDefaultSetup.jpg)

and linking the test target to ReactiveCocoa *doubles* the symbols because Xcode perform some dynamic code injection behind the scene.

## Getting out of the pit

There are multiple solutions to this, but, unfortunately, nothing straightforward which use CocoaPods. As I discovered, I am not the first one to stumble upon [this](https://github.com/CocoaPods/CocoaPods/issues/1411) and the feature is still [missing](https://github.com/CocoaPods/CocoaPods/issues/840).

So what can one do?

* One solution is to change your testing settings and stop testing against the Application. In this case, you need to compile all the code you want to test in your test target. This can be quite cumbersome because every time you add a class in your App, you may need to add it to your test target. Another problem is that you run your tests outside the context of your running App, this can be problematic in some cases.
* Another quicker solution I found was to add the Pods headers folder to the Test target's header path recursively: `$(PROJECT_DIR)/Pods/Headers`. This is kind of dirty, but it does the trick.
* Last, but not least, setting up your project/workspace entirely by yourself is, of course, a viable solution. I am still new to CocoaPods, and as I see its immediate value[^1], I am also wondering if relying on it in the long run might have some annoying downsides. I have been a long time user of git submodules. So you could still do this because you won't be relying of some generated settings on your project.

[^1]: injecting third-party libraries like if it was nothing

Maybe there are other solutions but, for now, I have just used the second one for my problem.

If you want to see an example of the problem, I shared [a project on github](https://github.com/Liquidsoul/ReactiveCocoaTestIssue).

I hope this will help someone!
