
# Minimalist FUSE Manager

---

## Configuration

Let's start by configuring `~/mnt/mfm.yml`!

---

---

## Configuration

We can add as many filesystems we want in the `filesystems:` list.

---

## Configuration

Each filesystem has a `type:` and specific configuration parameters

The current values supported by *mfm* are `gocryptfs`, `httpdirfs` and `sshfs`.

---

## Preparation

Before using *mfm*, lets have a look at the `~/mnt/` directory.

---

---

## Preparation

Yes, it is empty!

Don't worry, the mountpoint will be created automatically.

---

## Usage

Ok. Now, simply run *mfm* and choose your favorite filesystem!

In this demo, I will choose `Public - Debian Repository` which is a remote web
page hosting debian packages and registy catalog.

---

---

## Usage

Hmmm...

What happened?

---

## Usage

A directory was created in `~/mnt`.

It is filled with files and directories from a remote system, in which we can
navigate.

---

## Usage

Let's detach it now!

Simply run *mfm* again, and choose the same filesystem.

---

---

## Usage

It is now detached, and the directory is empty again!

---

## Conclusion

The *mfm* command works in the same way regardless of the filesystem selected.

It's simple, fast and efficient.

---

## Conclusion

The *mfm* project is still in its infancy.

We're looking for contributors to test it, to improve it, to make it even more
useful and enjoyable to use.

---

## Conclusion

But if you're just a user, we're already happy.

---

## Conclusion

Now it's your turn to use *mfm*!

