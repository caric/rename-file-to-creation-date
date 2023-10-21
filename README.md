# Rename a file with its creation date

## Introduction

rename a file to add its creation date and (optionally) time stamp to the beginning of the file name. uses `mdls` to get the content creation date and time.

YYYMMDDTHHMMSS filename

## Syntax

```shell
rename-to-creation.pl [--time] [--git] [--email] [-x] files
```

**--email** the file is an email; look for the "Date: " email header and convert its timezone, and use the email date if it's before the creation date. This is handy for emails you've dragged out of Mail.app to the finder; their creation time will be the time of the drag.

**--git** prepend the `mv` command with `git`

**--time** if specified, will also add 'Ttimestamp' to the filename.

**-x** or **--x** this flag causes the actual `mv` command to run; without this, rename-to-creation.pl just prints out what it would do but doesn't do anything.

## Examples

remember, it won't actually do the move until you add the `--x` flag. and you can use any shell globbing commands, such as `*.txt` or `insurance*.pdf`.

**Note:** this doesn't care if it's a file or a folder. 

### no flags

```shell
rename-to-creation.pl old.jpg
```

will look for a file name "old.jpg", use mdls to get its kMDItemContentCreationDate, and than rename the file. let's assume the file was created 2023-10-08 at 4:17:11pm (localtime). you'd see:

```shell
old.jpg
mv "old.jpg" "20231008 old.jpg"
```

### add timestamp

with the same file, if you ran `rename-to-creation.pl --time old.jpg` you'd see

```shell
old.jpg
mv "old.jpg" "20231008T161711 old.jpg"
```


