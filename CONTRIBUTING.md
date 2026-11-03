# Adding a listing

Every program on the site is written for it, tested in the lab and published with a full explanation. The steps below are the publishing checklist.

## 1. Write and test in the lab

1. Create `lab/programs/NAME.bas`. Lower case for normal text: it becomes C64 upper case.
2. `Ctrl+Shift+B` in VS Code. Fix every error in the Problems panel.
3. Run it in VICE and try every key and every path through the program. Take screenshots (VICE: *Snapshot > Save media file*) and, if it moves, a short recording.

## 2. Add it to the repository

```
listings/name/
  NAME.bas         the listing as published on the site
  NAME.prg         built by the lab
  name-*.png       screenshots from VICE
  README.md        category, size, keys, article link
```

- Copy the format of [`listings/zaria/README.md`](listings/zaria/README.md).
- Add a row to [`listings/README.md`](listings/README.md) and the table in the main [`README.md`](README.md), and update both directory blocks: blocks per file and `664 - total` blocks free.
- Add the name to the *Listing* dropdown in `.github/ISSUE_TEMPLATE/misprint.yml`.
- The `.prg` must always match the `.bas` and the listing on the site. A fix changes all three.

## 3. Publish on the site

1. Write the post in `blogger/posts/YYYY-MM-name.html`. Put the listing in
   `<script type="text/plain" class="listing" data-name="NAME"> ... </script>`.
2. Paste it into Blogger's HTML view.
3. Labels: `Listing` and one category (`Games`, `Graphics`, `Maths`, `Music`, `Utilities`...). Optionally `Disk:<name>` to group programs into a disk in the home page's Disk box.
4. Publish, then put the post URL in the listing's README and the tables.

## Corrections

Reports arrive through the [issue form](https://github.com/c64n/c64-coding/issues/new?template=misprint.yml). Reproduce the problem in VICE, fix the `.bas`, rebuild the `.prg`, update the article, and mention the fix in an `Errata` post on the site.
