# Ideas for future scripts and projects

- ChatGPT style AI that can replace my arch linux google search
- automate arch installation and post-installation via shell script
- better management and system restore
- how to back up app settings smartly - I think I got that figured out via symlinks...
- automate system update... via notification daemon or something?

## Ideas for this repo

- should contain a large archinstall script done by myself
- should contain modularized installers for features, applications, etc. - should be driven by config.
- can be run as single modules, no need to panic


## Implementation 

- the idea is there are a bunch of files here for config that I am storing
- I don´t really want to symlink all of them as they don't change as often
- create update script that takes a list of files, it will search for them and copy them to the correct location.
- I probably need a json config file that stores file names and file locations so I can easily drop them and update them - requires sudo tho.


- Troubleshooting app? 