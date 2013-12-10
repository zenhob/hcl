# Hacking HCl

## Running the tests

Use Bundler to install dependencies before you run the tests:

    gem install bundler
    bundle
    rake test

Coverage is tested automatically. To view the test coverage report:

    open coverage/index.html

## Running HCl during development

To run HCl in place (e.g. for testing out local changes) you can use bundle exec:

    bundle exec bin/hcl

## Generating API documentation

To generate and view the API documentation:

    rake doc
    open doc/index.html
