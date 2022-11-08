# Script directory imported from svn

```bash
git svn clone https://gtsvn.uit.no/langtech/trunk/gt/script old_gt_script --authors-file clean_lang_history/svn2git-authors.txt
cd old_gt_script/
git filter-repo  --force  --prune-empty always --strip-blobs-bigger-than 50M --replace-refs delete-no-add --prune-degenerate always --replace-message ../clean_lang_history/replacements.txt --message-callback ../clean_lang_history/replace_git_svn.py --mailmap ../clean_lang_history/all-repos.mailmap
```

The files in the clean_lang_history directory are files found in <https://github.com/giellalt/clean_lang_history>
