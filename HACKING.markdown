# Hacking HCl

## Rubygems

They're useful so we use them to install our gems. However there's no need to
explicitly include rubygems in the app. That's up the system to decide. Don't
require rubygems in the code.

We require rubygems in the test as a developer convenience.

## Running HCl in place

This is common and supported:

  ruby -rubygems -Ilib bin/hcl

Don't add dir(__FILE__)/lib to the load path in the binary. Bad manners.

## That's it

That's it. I mostly wrote this to explain why I rolled back certain changes.
