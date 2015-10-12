# code-craftsman blog

This is the source of my personal blog.

It uses [Lanyon](https://github.com/poole/lanyon) theme for [Jekyll](http://jekyllrb.com) created by [Mark Otto](https://twitter.com/mdo) and open sourced under the [MIT license](LICENSE.md).

## Deployment workflow

I use [Fastlane](http://fastlane.tools) to define my deployment pipeline. 
Because the tools are in Ruby, I use [Bundler](http://bundler.io) to manage my dependencies.

### Prerequisites

First, run `setup.sh`. This will run `bundler` for a local installation.

### Build

To build the site into the `_site` folder use:

    $ bundle exec jekyll build

### Serve

To serve the site run:

    $ bundle exec jekyll serve

