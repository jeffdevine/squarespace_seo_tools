# Squarespace SEO Tools
Tools that use OpenAI to help improve SEO for a Squarespace-hosted Blog

## Overview
This was an experiment to use [OpenAI](https://openai.com) to generate JSON-LD FAQ [schema.org](https://schema.org) from blog posts.

I had a blog hosted on Squarespace that I wanted JSON-LD entries for [SREP FAQs](https://developers.google.com/search/docs/appearance/structured-data/faqpage) and there is no automated way to do this. I'd originally set out to have OpenAI convert the HTML into JSON-LD, but that was using an LLM to solve the wrong problem.

The codebase has evolved into a few tools that use OpenAI to help improve SEO for a Squarespace-hosted Blog:

 - `blog_post_scrapper` - Gently scrapes the blog posts and saves them locally
 - `blog_post_seo_tools` - Uses the local cahce of blog posts and uses OpenAI to suggest better titles and descriptions
 - `blog_post_to_json_ld` - Converts the blog posts into JSON-LD FAQ files and optionally can optimize the `answer` with OpenAI

Note that these tools make the following huge assumptions:

- The blog is hosted at `/blog`
- Each blog is structured to use `h2` and `p` for questions and answers respectively
- The local directory `./blog` is the local cache of all blog posts (this is what `blog_post_scrapper` sorts)

### To Do

- [ ] Test coverage everywhere
- [ ] Moving share logic into services
- [ ] `blog_post_seo_tools` still needs work and ideally would use a more sophistcated prompt rather than multiple calls to OpenAI
- [ ] `blog_post_scrapper` should take a date as input and only scrape posts that are newer than that date

# Installation

## macOS

To install everything locally, you'll need the following:

* Ruby 3.1.x

### Ruby
You can install and manage your rubies using any tool you want. The following describes how to manage it with [Homebrew](https://brew.sh) and [asdf](https://asdf-vm.com).

First, install [Homebrew](https://brew.sh):

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Next use, `homebrew` to install `asdf`:

```
brew install asdf
```

For zsh users (macOS default as of 10.5+), load `asdf` automatically by appending the following to your shell configuration (`~/.zshrc`):

```
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
```

Clone the latest code from github

```
git clone git@github.com:jeffdevine/squarespace_seo_tools.git
```

Change to the source directory

```
cd squarespace_seo_tools
```

Run `bundle` to install the required gems:

```
bundle install
```

### Development Tools
To run the test suite, execute:

```
bundle exec rspec
```

To look for code and linting issues, run the following:

```
bundle exec rubocop
```
