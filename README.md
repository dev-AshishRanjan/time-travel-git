# Time Travel Git

> **_For Educational Purpose Only_**

we tried to make the time travel as easy and intuitive as possible for Git/Github. Here's a quick guide on how you can use it:

1. clone this repo

```sh
git clone https://github.com/dev-AshishRanjan/time-travel-git
```

2. Run the script named `run.sh`, use git bash terminal to run the below command when you are in the root directory of the cloned repo

```sh
./run.sh dev-AshishRanjan test 50 true
```

This will push the changes also 👍🏽

Arguments (in order):

1. GITHUB USERNAME
2. GITHUB REPO NAME
3. NO. OF DAYS
4. PAST? : this is optional argument, by default true. If given false, then commits will be done for future not past.

> NOTE: You shold be allowed to push to the github repo, whose name is given as argument when you run the script `run.sh`

## Prerequisite

1. A clean **GitHub Repository** on your GitHub account, which is passed as argument to the script
