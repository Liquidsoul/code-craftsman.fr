---
layout: post
title: Saving CoreData objects
---

The associated playground can be found [in this repo](https://github.com/Liquidsoul/coredata-saving-contexts)!

## Introduction

I am quite new at using Core Data.
I have started to use it just a few months back, and I've been using it extensively the last couple of month.
During this time, I have learned some things about `NSManagedObjectContext` that I want to share.
Here, I'll be explaining how the saving mechanism works with multiple contexts created using different methods.

We'll be working with very basic Core Data model which will contain only one single entity.

	+-----------------+
	| Person          |
	+-----------------+
	| name            |
	+-----------------+

Here is our context:
 * we've got a main context that is used by our controllers
 * we want to refresh our data using server requests and store it asynchronously to Core Data (server requests are another topic so we will skip this part)

## The first approach
To get started quickly with our topic, let's perform the heavy lifting of creating the model and persistent store coordinator behind the scene:

{% highlight swift %}
import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()

{% endhighlight %}
So now, back to our topic.

So let's setup our main context:
{% highlight swift %}
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator

{% endhighlight %}
As we want to share data between contexts, let's create a child context for our background update:
{% highlight swift %}
let childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
childContext.parentContext = mainContext

{% endhighlight %}
Let's create a new entity in the child context as if it came from the server:
{% highlight swift %}
let person = addPersonToContext(childContext, name: "John")

{% endhighlight %}
Now we save our content [^1]:

[^1]: Note that you should use `performBlock()` to execute calls on a `NSManagedObjectContext` to ensure that the correct thread is using it.
{% highlight swift %}
try childContext.save()

{% endhighlight %}
let's check that we have the new content in the main context using a fetch request:
{% highlight swift %}
let results = try mainContext.executeFetchRequest(NSFetchRequest(entityName: "Person"))
if let createdPerson = results.first as? Person {
	print(createdPerson)	// "name: John"
} else {
	print("Noone there!")
}

{% endhighlight %}
Yes! Everything seems ok.

To be sure, let's just check if everything was saved in the persistent store using a third context as if we were launching our app again:
{% highlight swift %}
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

{% endhighlight %}
and fetch our data:
{% highlight swift %}
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(NSFetchRequest(entityName: "Person")).first as? Person {
	print(createdPerson)
} else {
	print("Noone there!")	// "Noone there!"
}

{% endhighlight %}
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
To save it to the persistent store, you'll need to performs `save()` calls on context all the way up in the hierarchy.



## Fixing our first approach


So, we have our initial setup.

{% highlight swift %}
import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator

{% endhighlight %}
But to spice it a little, let's create another entity that will be living in the main context.
Note that this entity could've come from another child context:
{% highlight swift %}
let ourOtherPerson = addPersonToContext(mainContext, name: "Billy")

{% endhighlight %}
And then let's say we've got our server data we want to save in the persistent store:
{% highlight swift %}
let childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
childContext.parentContext = mainContext
let person = addPersonToContext(childContext, name: "John")

{% endhighlight %}
Now, as we've learned before, we save our content from the child to the main context[^2]:

[^2]: as told before[^1], don't forget to use `performBlock()` to call CoreData context code
{% highlight swift %}
try childContext.save()
try mainContext.save()

{% endhighlight %}
So now we should have saved our "John" in the persistent store, let's check that:
{% highlight swift %}
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

let fetchRequest = NSFetchRequest(entityName: "Person")
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "John")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: John"
} else {
	print("Noone there!")
}

{% endhighlight %}
Problem solved!

But wait... what happened to our "Billy". We wanted to store "John" into the persitent store, not "Billy":
{% highlight swift %}
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "Billy")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: Billy"
} else {
	print("Noone there!")
}

{% endhighlight %}
Oh no! We've saved "Billy" as well!

Yet, this seems coherent with the fact that, as we've performed a `save()` on the main context, *all* objects it contains are saved.

So what can we do if we only want to save John without saving Billy?


## Confined save

So, as before, our main context with our "Billy"

{% highlight swift %}
import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator
let ourOtherPerson = addPersonToContext(mainContext, name: "Billy")

{% endhighlight %}
Therefore, to prevent "Billy" to be saved while we just wanted to save "John", we will not create our editing context from the main one.
We will create what I call a *sibling* context which share the same store as the main one:

{% highlight swift %}
let siblingContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
siblingContext.persistentStoreCoordinator = persistentStoreCoordinator
let person = addPersonToContext(siblingContext, name: "John")

{% endhighlight %}
Now, all we have to do is save the sibling context:
{% highlight swift %}
try siblingContext.save()

{% endhighlight %}
Let's check that we can access our "John" from our main context:
{% highlight swift %}
let fetchRequest = NSFetchRequest(entityName: "Person")
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "John")
if let createdPerson = try mainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: John"
} else {
	print("Noone there!")
}

{% endhighlight %}
Yes! Now let's see if "Billy" was saved:
{% highlight swift %}
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "Billy")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)
} else {
	print("Noone there!")	// "Noone there!"
}

{% endhighlight %}
We did it!

## Conclusion

We learned that:

* calling `save()` on a context will only send changes one step up the hierarchy
* `save()` will commit changes contained in the whole context

As a side note: for the sake of simplicity here, we have only worked with entity insertion.
When you start playing with entity attributes, you'll need to perform some `refreshObject()` calls to see the saved values in other contexts.
