# GPT JSON-LD Fun

This is an experiment to use [OpenAI](https://openai.com) to generate JSON-LD FAQ [schema.org](https://schema.org) from blog posts.

I had a blog hosted on Squarespace that I wanted JSON-LD entries for [SREP FAQs](https://developers.google.com/search/docs/appearance/structured-data/faqpage) and there is no automated way to do this. I had to manually create each entry. I would like to know if I can use OpenAI to generate the JSON-LD for me.

Because of how the blog is structured, I'm making these massive assumptions:

- The blog is hosted at `/blog`
- Each blog is structured to use `h2` and `p` for questions and answers respectively
- There is some human intervention to glue the components together

## To Do
- [ ] OpenAI-assisted web scraper
- [ ] Send each blog post to OpenAI to get summarizations for each question/answer
- [ ] Have OpenAI covert `h2`/`p` to JSON-LD.

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
git clone git@github.com:jeffdevine/gpt-json-ld-fun.git
```

Change to the source directory

```
cd gpt-json-ld-fun
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
