# Custom Scripts

This repo stores small utility scripts for various usecases. Mostly related to linux machine operations.

## Scripts

### dotfile-management

Utilities used to manage dotfile (i.e. .config, .bashrc, etc.) backups with a bare git repository.

- [dotfile-clone-repo](dotfile-management/dotfile-clone-repo.sh) - used to set up a new machine and clone an existing dotfiles repo
- [dotfile-backup](dotfile-management/dotfile-backup.sh) - used to commit a list of files for backup
- [dotfile-delete](dotfile-management/dotfile-delete.sh) - used to remove a list of files from backup
- [dotfile-git-from-scratch](dotfile-management/dotfile-git-from-scratch.sh) - create a new directory for dotfile backup, assuming you have an empty repository created to host the data


## Script Ideas

- Script that takes a shell file and turns into an executable in /usr/bin.. loop for one time setup, should work in directory somehow?

