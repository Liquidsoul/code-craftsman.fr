---
layout: post
title: Saving CoreData objects
---

The associated playground can be found [in this repo](https://github.com/Liquidsoul/coredata-saving-contexts)!

## The context

I am quite new at using Core Data.
I have started to use it just a few months back, and I've been using it extensively the last couple of months.
During this time, I have learned some things about `NSManagedObjectContext` that I want to share.
Here, I'll explain how the saving mechanism works with multiple contexts created using different methods.

We'll work with a very basic Core Data model which will contain only one single entity.

	+-----------------+
	| Person          |
	+-----------------+
	| name            |
	+-----------------+

Here is our context:

 * we've got a main context that is used by our controllers
 * we want to refresh our data using server requests and store it asynchronously to Core Data (server requests are another topic so we will skip this part)

## The first approach
To get started quickly with our topic, the heavy lifting of creating the model and persistent store coordinator will be done behind the scene[^1]:

```swift
import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()

```
Now that we have our persistentStoreCoordinator, we create our main context:
```swift
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator

```
As we want to share data between the two contexts, we create a child context for our background update:
```swift
let childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
childContext.parentContext = mainContext

```
Then, we create a new entity in the child context as if it came from the server[^1]:
```swift
let person = addPersonToContext(childContext, name: "John")

```
Now we save our content[^2]:
```swift
try childContext.save()

```
Let's check that we have the new content in the main context using a fetch request:
```swift
let results = try mainContext.executeFetchRequest(NSFetchRequest(entityName: "Person"))
if let createdPerson = results.first as? Person {
	print(createdPerson)	// "name: John"
} else {
	print("Noone there!")
}

```
Yes! Everything seems ok.

To be sure, let's just check if everything was saved in the persistent store using a third context as if we were launching our app again:
```swift
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

```
and fetch our data:
```swift
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(NSFetchRequest(entityName: "Person")).first as? Person {
	print(createdPerson)
} else {
	print("Noone there!")	// "Noone there!"
}

```
Wait, what? There is no data? What happened?

Here is the first important lesson to learn.
Let's have a look at the official documentation of `save()`:

	Attempts to commit unsaved changes to registered objects to the receiver’s
	parent store.

This can be misleading. When one see `parent store` he can understand `the parent persitent store of my context hierarchy`.
However, what is meant by `parent store` is either:

* the persistentStoreCoordinator
* the parentContext

So, if your context was setup with a parent context, changes are commited to his parent but no further.
To save it to the persistent store, you'll need to call `save()` on contexts all the way up in the hierarchy until you reach the persistent store.


[^1]: `createPersistentStoreCoordinator` and `addPersonToContext` are helper functions to shorten the code in the article. You can find the code [here] [CoreDataSetup]
[^2]: Note that you should use `performBlock()` to execute calls on a `NSManagedObjectContext` to ensure that the correct thread is using it.
[CoreDataSetup]: https://github.com/Liquidsoul/coredata-saving-contexts/blob/master/CoreDataSavingContexts.playground/Sources/CoreDataSetup.swift


## Fixing our first approach


So, we have our initial setup.

```swift
import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator

```
But to spice it a little, let's create another entity that will exist in the main context.
For example, this entity could've come from another child context:
```swift
let ourOtherPerson = addPersonToContext(mainContext, name: "Billy")

```
Now, we continue as before with the server data we want to save in the persistent store:
```swift
let childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
childContext.parentContext = mainContext
let person = addPersonToContext(childContext, name: "John")

```
Now, as we've learned before, we save our content in the child context and then in the main context[^3]:
```swift
try childContext.save()
try mainContext.save()

```
We have saved our "John" in the persistent store, let's check that:
```swift
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

let fetchRequest = NSFetchRequest(entityName: "Person")
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "John")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: John"
} else {
	print("Noone there!")
}

```
Problem solved!

But wait... what happened to our "Billy". We wanted to store only "John" into the persitent store, not "Billy":
```swift
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "Billy")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: Billy"
} else {
	print("Noone there!")
}

```
Oh no! We've saved "Billy" as well!

Yet, this seems coherent with the fact that, as we've performed a `save()` on the main context, *all* objects it contains are saved.

So what can we do if we only want to save John without saving Billy?

[^3]: as told before[^2], don't forget to use `performBlock()` to call CoreData context code


## Confined save

Let's do it again, we setup our main context with "Billy"

```swift
import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator
let ourOtherPerson = addPersonToContext(mainContext, name: "Billy")

```
Then, to prevent "Billy" to be saved while we just want to save "John", we will not create our editing context as a child of the main.
We will create what we'll call a *sibling* context. These are contexts that share the same persitent store coordinator:

```swift
let siblingContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
siblingContext.persistentStoreCoordinator = persistentStoreCoordinator
let person = addPersonToContext(siblingContext, name: "John")

```
Now, all we have to do is save the sibling context:
```swift
try siblingContext.save()

```
Let's check that we can access our "John" from our main context:
```swift
let fetchRequest = NSFetchRequest(entityName: "Person")
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "John")
if let createdPerson = try mainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: John"
} else {
	print("Noone there!")
}

```
Yes! Now let's see if "Billy" was saved:
```swift
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "Billy")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)
} else {
	print("Noone there!")	// "Noone there!"
}

```
We did it!

## Conclusion

Here, we learned that:

* calling `save()` on a context will only send changes one step up the hierarchy
* `save()` will commit changes contained in the whole context

I hope that this may help anyone who did not yet grasp how Core Data save its content throught contexts.


__As a side note__: for the sake of simplicity here, we have only worked with entity insertion.
When you start playing with entity attributes, you'll need to perform some [`refreshObject(_:mergeChanges:)`](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObjectContext_Class/index.html#//apple_ref/occ/instm/NSManagedObjectContext/refreshObject:mergeChanges:) calls to see the saved values in other contexts.
