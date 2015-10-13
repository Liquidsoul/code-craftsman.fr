# code-craftsman blog

This is the source of my personal blog.

It uses [Lanyon](https://github.com/poole/lanyon) theme for [Jekyll](http://jekyllrb.com) created by [Mark Otto](https://twitter.com/mdo) and open sourced under the [MIT license](LICENSE.md).

The markdown source of the site is in the `source` branch while the result pages are stored in the `gh-pages` branch.

## Deployment workflow

I use [Fastlane](http://fastlane.tools) to define my deployment pipeline.  
Because the tools used here are in Ruby, I use [Bundler](http://bundler.io) to manage my dependencies.  
Everything that follows must be run on the `source` branch.

### Prerequisites

First, run `setup.sh`. This will run `bundler` and install the tools locally just for the repo.

### Build

To build the site into the `_site` folder use:

    $ bundle exec jekyll build

or

    $ bundle exec fastlane build

### Serve

To serve the site run:

    $ bundle exec jekyll serve

or

    $ bundle exec fastlane serve

Note that in this case, you'll have to manually kill the jekyll instance. See the output for details. 

### Deploy

To deploy the site into its dedicated branch run:

    $ bundle exec fastlane deploy
