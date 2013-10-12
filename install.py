#!/usr/bin/env python

from __future__ import print_function
import glob
import os
import sys


DEBUG = True

IGNORED_FILES = set(['.git'])
OVERWRITE_TO_ALL = ''  # can be: 'y', 'n', '' (ask)


def main(argv):
    dot_dir = os.path.dirname(os.path.abspath(__file__))
    home_dir = os.path.dirname(dot_dir)

    print('Home directory: %s' % home_dir)
    print('Dot directory: %s' % dot_dir)
    print()

    for rc_file in glob.glob(os.path.join(dot_dir, '.*')):
        rc_filename = os.path.basename(rc_file)  # eg: .pyrc

        if rc_filename in IGNORED_FILES:
            continue

        print('Check for "%s" ...' % rc_filename, end=' ')
        if rc_filename == '.bashrc':
            # append this at the end of the .bashrc: ". ~/.dotfiles/.bashrc"
            bashrc_file = os.path.join(home_dir, rc_filename)  # /home/user/.bashrc
            source_cmd = '. %s' % (os.path.join('~', os.path.basename(dot_dir), '.bashrc'))  # eg: ". ~/.dotfiles/.bashrc
            if not os.path.exists(bashrc_file):
                with open(bashrc_file, 'w'):
                    pass

            if (os.path.islink(bashrc_file) and
                    os.path.abspath(os.path.join(os.path.dirname(bashrc_file), os.readlink(bashrc_file))) == os.path.abspath(rc_file)):
                print('Skipped: "%s" is a symlink -> "%s".' % (bashrc_file, os.readlink(bashrc_file)))
                continue

            found = False
            with open(bashrc_file) as fh:
                for line in fh:
                    if line.strip() == source_cmd:
                        found = True
                        break

            if found:
                # nothing to do
                print('Found the bashrc sourcing in "%s"' % bashrc_file)
            else:
                # append to ~/.bashrc
                print('Append bashrc sourcing to "%s"' % bashrc_file)
                with open(bashrc_file, 'a') as fh:
                    fh.write('\n')
                    fh.write('# bashrc customization\n')
                    fh.write(source_cmd)

        else:
            # default action: create a symlink
            symlink = os.path.join(home_dir, rc_filename)  # eg: /home/user/.pyrc
            symlink_target = os.path.join(os.path.basename(os.path.dirname(rc_file)), rc_filename)  # eg: .dotfiles/.pyrc
            if os.path.lexists(symlink):
                # already exists
                if os.path.islink(symlink):
                    if os.readlink(symlink) != symlink_target:
                        if get_overwrite_answer('Symlink "%s" -> "%s" already exists. Overwrite? (y)es or [Enter] / (Y)es to all / (n)o / (N)o to all / (a)bort: ' % (symlink, os.readlink(symlink))):
                            create_symlink(symlink_target, symlink, overwrite=True)
                    else:
                        print('OK.')
                elif os.path.isfile(symlink):
                    if get_overwrite_answer('File "%s" already exists. Overwrite? (y)es or [Enter] / (Y)es to all / (n)o / (N)o to all / (a)bort: ' % symlink):
                        create_symlink(symlink_target, symlink, overwrite=True)
                elif os.path.isdir(symlink):
                    print('Directory "%s" already exists. Do something about it. Abort.' % symlink)
                    sys.exit(1)
            else:
                create_symlink(symlink_target, symlink)

    print('Done.')


def get_overwrite_answer(message):
    global OVERWRITE_TO_ALL
    if OVERWRITE_TO_ALL == 'y':
        return True
    elif OVERWRITE_TO_ALL == 'n':
        return False
    else:
        # ask
        answer = get_input(message).strip()
        if answer in ['y', '', 'Y']:
            # yes
            if answer == 'Y':
                OVERWRITE_TO_ALL = 'y'
            return True
        elif answer == 'a':
            # abort
            print('Abort.')
            sys.exit(0)
        else:
            # no
            if answer == 'N':
                OVERWRITE_TO_ALL = 'n'
            return False


def create_symlink(source, link_name, overwrite=False):
    print('Create symlink "%s" -> "%s"' % (link_name, source))
    if overwrite and os.path.lexists(link_name):
        os.remove(link_name)
    os.symlink(source, link_name)


if sys.version_info < (3,):
    # python 2
    get_input = raw_input
else:
    # python 3
    get_input = input


if __name__ == '__main__':
    main(sys.argv)
