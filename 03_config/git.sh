#!/usr/bin/env fish

git config --global user.useConfigOnly true
git config --global pull.rebase true

# https://github.com/so-fancy/diff-so-fancy

git config --global core.pager "diff-so-fancy | less --tabs=4 -+\$LESS -RF"
git config --global interactive.diffFilter "diff-so-fancy --patch"

git config --global color.ui true                                                                                                                Tue Mar 23 13:52:39 2021

git config --global color.diff-highlight.oldNormal    "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal    "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global color.diff.meta       "11"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.func       "146 bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"
