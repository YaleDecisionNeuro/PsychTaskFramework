# Contributing

We welcome contributions from everyone.

To organize contributions, this project uses something called git flow. This means:

1. The `master` branch is never directly worked on.
2. To work on PTF, you'll need to create a git branch, make your changes there, push them, and submit a pull request.
3. The pull request can be reviewed and commented on; you might be asked to make some changes.
4. When your feature/bugfix is complete and ready, the changes in the pull request are merged.

[This GitHub article goes over the general outline of the process.](https://guides.github.com/introduction/flow/) [This gist includes specific commands you might want to use,](https://gist.github.com/Chaser324/ce0505fbed06b947d962) as does [this article](http://www.eqqon.com/index.php/Collaborative_Github_Workflow).

(If you're interested in different git workflows, check out ["Git workflows that work"](http://blog.endpoint.com/2014/05/git-workflows-that-work.html).)

## Branches and issues

Typically, each branch will correspond to an issue filed in our Github issue tracker. If you discover a bug or desire a feature, check the issue tracker to see if someone hasn't already done so. Name the branch that you'll be working on accordingly.

For example, if you wish to implement the matter of issue #313, which suggests a feature that would allow users to fly, you could name the branch `313_antigravity`.

## Commits

Descriptive commits are highly preferred. Please see [The Art of a Commit](https://alistapart.com/article/the-art-of-the-commit) by _A List Apart_.

# Conventions

* We indent with two spaces (soft tabs)
* Spaces belong:
	* after method parameters, e.g. `sprintf(a, b)` 
	* before and after operators, e.g. `1 + 2`
* Spaces never belong between function name and braces, i.e. `thisFunction()`.
* Each function should have a comment that explains what it does and why.
* Functions and variable names are written with snakeCase.

# Practical matters

## Setup

You'll need Matlab and PsychToolBox. For more info, see the README.

## Forks

While all members of the YaleDecisionNeuro team can create branches on the main repository, I strongly suggest working on your own forks. Note that **you can file a pull request and continue working -- the pull request is for a branch, not for a specific commit that was its `HEAD` at the time of PR submission**.

## Getting updates

Your feature branch should base off of the `HEAD` (i.e. latest commit) of the master branch.

To tell your local version that it has an upstream remote repo, run once
`git remote add upstream https://github.com/YaleDecisionNeuro/PsychTaskFramework.git`.

To get the latest changes from PTF, you'll want to run `git pull --rebase upstream master` on your feature branch (and, optionally, your master branch). 

Again, [see this general outline of the process](https://guides.github.com/introduction/flow/) and [this gist with specific commands you might want to use.](https://gist.github.com/Chaser324/ce0505fbed06b947d962)

### Troubleshooting

If you have unsaved changes that you are not prepared to commit, you may wish to "stash" them with `git stash`, run `git pull --rebase upstream master`, and then load your stashed changes with `git stash pop`. Alternatively, you can set your `.gitconfig` so that this behavior is triggered otherwise:

* `git config --global rebase.autoStash true` will always save and load unstaged changes automatically when you run `git pull --rebase` and `git rebase`
* `git config --global alias.sync 'pull --rebase --autostash upstream master'` will create a command `git sync` that will run the required command.

If you wish `git pull` to always rebase rather than create a merge commit, you can set such behavior with `git config --global pull.rebase preserve`.
