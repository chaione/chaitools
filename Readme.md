#Brew some awesome apps with ChaiTools

##Installation

ChaiTools can be installed using Homebrew and a custom Homebrew tap.

```brew tap chaione/c1tap```

```brew install chaitools```

##Current Actions

* `templates` - Install, update, or delete Xcode templates
* `bootstrap` - Bootstraps a new C1 project.

### bootstrap

Running `bootstrap` alone will give you the option to setup a default file structure.

Running `bootstrap <techstack>` will run the bootstrapper specific for that technology stack. Currently supported technology stacks include:

* android
