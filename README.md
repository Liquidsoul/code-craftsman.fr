# code-craftsman blog

This is the source of my personal blog.

It uses [Lanyon](https://github.com/poole/lanyon) theme for [Jekyll](http://jekyllrb.com) created by [Mark Otto](https://twitter.com/mdo) and open sourced under the [MIT license](LICENSE.md).

The markdown source of the site is in the `source` branch while the result pages are stored in the `gh-pages` branch.

## Deployment workflow

I use [Fastlane](http://fastlane.tools) to define my deployment pipeline.  
Because the tools used here are in Ruby, I use [Bundler](http://bundler.io) to manage my dependencies.  
And to have a single point of entry that is available everywhere, I use `make`.

Everything that follows must be run on the `source` branch.

### Build

To build the site into the `_site` folder use:

    $ make build

### Serve

To serve the site run:

    $ make serve

### Deploy

To deploy the site into its dedicated branch run:

    $ make deploy

Once this is done, you'll have to push the changes to the remote to complete the deployment.

### Other

You can see all the available `make` commands using:

    $ make help
