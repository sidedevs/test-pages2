---
title: Jekyll on Ubuntu
permalink: /docs/installation/ubuntu/
---

## Install dependencies

Install Ruby and other [prerequisites]({{ '/docs/installation/#requirements' | relative_url }}):

```sh
sudo apt-get install ruby-full build-essential zlib1g-dev
```

Avoid installing RubyGems packages (called gems) as the root user. Instead, 
set up a gem installation directory for your user account. The following
commands will add environment variables to your `~/.bashrc` file to configure
the gem installation path:

```sh
echo '# Install Ruby Gems to ~/.local/share/gem' >> ~/.bashrc
echo 'export GEM_HOME="$(ruby -e "puts Gem.user_dir")"' >> ~/.bashrc
echo 'export PATH="$PATH:$GEM_HOME/bin"' >> ~/.bashrc
source ~/.bashrc
```

Finally, install Jekyll and Bundler:

```sh
gem install jekyll bundler
```

That's it! You're ready to start using Jekyll.
